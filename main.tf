data "ibm_resource_group" "rg_name" {
  name = var.resource_group_name
}

module "hpcs_instance" {
  source                 = "../../modules/hpcs-instance"
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

module "download_from_cos" {
  count           = var.initialize ? 1 : 0
  source          = "../../modules/hpcs-initialisation/download-from-cos"
  api_key         = var.api_key
  cos_crn         = var.cos_crn
  endpoint        = var.endpoint
  bucket_name     = var.bucket_name
  input_file_name = var.input_file_name
}

module "hpcs_init" {
  count              = var.initialize ? 1 : 0
  source             = "../../modules/hpcs-initialisation/hpcs-init"
  depends_on         = [module.download_from_cos]
  tke_files_path     = var.tke_files_path
  input_file_name    = var.input_file_name
  hpcs_instance_guid = data.ibm_resource_instance.hpcs_instance.guid
}

module "upload_to_cos" {
  source             = "../../modules/hpcs-initialisation/upload-to-cos"
  depends_on         = [module.hpcs_init]
  api_key            = var.api_key
  cos_crn            = var.cos_crn
  endpoint           = var.endpoint
  bucket_name        = var.bucket_name
  tke_files_path     = var.tke_files_path
  hpcs_instance_guid = data.ibm_resource_instance.hpcs_instance.guid
}

resource "null_resource" "enable_policies" {
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash scripts/network_policy.sh"

    environment = {
      REGION               = var.region
      HPCS_INSTANCE_ID     = data.ibm_resource_instance.hpcs_instance.guid
      ALLOWED_NETWORK_TYPE = var.allowed_network_type
      PORT                 = var.hpcs_port
    }
  }
  provisioner "local-exec" {
    when    = create
    command = "/bin/bash scripts/dual_authorization_policy.sh"

    environment = {
      REGION           = var.region
      HPCS_INSTANCE_ID = data.ibm_resource_instance.hpcs_instance.guid
    }
  }
}

module "ibm-hpcs-kms-key" {
  source          = "../../modules/hpcs-kms-key/"
  instance_id     = data.ibm_resource_instance.hpcs_instance.guid
  name            = var.name
  standard_key    = var.standard_key
  force_delete    = var.force_delete
  endpoint_type   = var.endpoint_type
  key_material    = var.key_material
  encrypted_nonce = var.encrypted_nonce
  iv_value        = var.iv_value
  expiration_date = var.expiration_date
}


