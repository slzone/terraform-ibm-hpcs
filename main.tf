# Get the name of resource group
data "ibm_resource_group" "rg_name" {
  name = var.resource_group_name
}

# Create hpcs instance if provision flag is true
module "hpcs_instance" {
  provision              = var.provision
  source                 = "./modules/hpcs-instance"
  resource_group_name    = data.ibm_resource_group.rg_name.id
  region                 = var.region
  name_prefix            = var.name_prefix
  tags                   = var.tags
  plan                   = var.plan
  service_endpoints      = var.service_endpoints
  number_of_crypto_units = var.number_of_crypto_units
}

data "ibm_resource_instance" "hpcs_instance" {
  name              = var.service_name
  resource_group_id = data.ibm_resource_group.rg_name.id
  service           = var.service_name
}

# Download the input.json file from COS bucket
module "download_from_cos" {
  source          = "./modules/hpcs-initialisation/download-from-cos"
  api_key         = var.api_key
  cos_crn         = var.cos_crn
  endpoint        = var.endpoint
  bucket_name     = var.bucket_name
  input_file_name = var.input_file_name
}

# Initialize the HPCS instance if initialize flag is true
module "hpcs_init" {
  count              = var.initialize ? 1 : 0
  source             = "./modules/hpcs-initialisation/hpcs-init"
  depends_on         = [module.download_from_cos]
  tke_files_path     = var.tke_files_path
  input_file_name    = var.input_file_name
  hpcs_instance_guid = data.ibm_resource_instance.hpcs_instance.guid
}

# Uplaod the signature key to provided COS bucket
module "upload_to_cos" {
  source             = "./modules/hpcs-initialisation/upload-to-cos"
  depends_on         = [module.hpcs_init]
  api_key            = var.api_key
  cos_crn            = var.cos_crn
  endpoint           = var.endpoint
  bucket_name        = var.bucket_name
  tke_files_path     = var.tke_files_path
  hpcs_instance_guid = data.ibm_resource_instance.hpcs_instance.guid
}

# Enable the HPCS policies 
resource "null_resource" "enable_policies" {
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash scripts/network_policy.sh"

    environment = {
      REGION                     = var.region
      HPCS_INSTANCE_ID           = data.ibm_resource_instance.hpcs_instance.guid
      ALLOWED_NETWORK_TYPE       = var.allowed_network_type
      PORT                       = var.hpcs_port
      DUAL_AUTH_DELETION_ENABLED = var.dual_auth_deletion_enabled
    }
  }
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash scripts/dual_authorization_policy.sh"

    environment = {
      REGION           = var.region
      HPCS_INSTANCE_ID = data.ibm_resource_instance.hpcs_instance.guid
      ALLOWED_NETWORK  = var.allowed_network
    }
  }
}

# Create kms key
module "ibm-hpcs-kms-key" {
  source          = "./modules/hpcs-kms-key/"
  instance_id     = data.ibm_resource_instance.hpcs_instance.guid
  name            = var.name
  standard_key    = var.standard_key
  force_delete    = var.force_delete
  endpoint_type   = var.endpoint_type
  key_material    = var.key_material
  encrypted_nonce = var.encrypted_nonce
  iv_value        = var.iv_value
  expiration_date = var.expiration_date
  interval_month  = var.interval_month
  enabled         = var.dual_auth_enabled
}

# Enable dual deletion authorization policy for the KMS key
resource "null_resource" "enable_key_rotaion_policy" {
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash scripts/key_rotation_policy.sh"

    environment = {
      REGION           = var.region
      HPCS_INSTANCE_ID = data.ibm_resource_instance.hpcs_instance.guid
      INTERVAL_MONTH   = var.interval_month
      PORT             = var.hpcs_port
    }
  }
}

