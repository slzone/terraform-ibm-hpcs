variable "service_name" {
  type        = string
  description = "Name of HPCS Instance"
  default     = "hs-crypto"
}

variable "region" {
  default     = "us-south"
  type        = string
  description = "Location of HPCS Instance"
}

variable "plan" {
  default     = "standard"
  type        = string
  description = "Plan of HPCS Instance"
}

variable "service_endpoints" {
  default     = null
  type        = string
  description = "Types of the service endpoints. Possible values are 'public', 'private', 'public-and-private'."
}

variable "tags" {
  default     = null
  type        = set(string)
  description = "Tags for the cms"
}

variable "number_of_crypto_units" {
  type        = number
  description = "No of crypto units that has to be attached to the instance."
  default     = 1
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "slz-rg"
}

# COS Credentials
variable "api_key" {
  type        = string
  description = "api key of the COS bucket"
  default     = "86NKy0nCPtXk6U8mbs1aPK9gqdP3y2HgvmpxKWH6BgvW"
}

variable "cos_crn" {
  type        = string
  description = "COS instance CRN"
  default     = "crn:v1:bluemix:public:iam-identity::a/ad5d072102214f4395eab22f03bbb2f9::serviceid:ServiceId-b5f7330c-5a56-4786-9488-11f76accde52"
}

variable "endpoint" {
  type        = string
  description = "COS endpoint"
  default     = "s3.us-east.cloud-object-storage.appdomain.cloud"
}

variable "bucket_name" {
  type        = string
  description = "COS bucket name"
  default     = "cloud-object-storage-5a-cos-standard-1mk"
}

variable "input_file_name" {
  type        = string
  description = "Input json file name that is present in the cos-bucket or in the local"
  default     = "./input.json"
}

# Path to which CLOUDTKEFILES has to be exported
variable "tke_files_path" {
  type        = string
  description = "Path to which tke files has to be exported"
  default     = "/Users/aparnamane/tke-files"
}

variable "name" {
  description = "Name of the Key"
  type        = string
  default     = "root-key-1"
}

variable "standard_key" {
  description = "Determines if it is a standard key or not"
  default     = null
  type        = bool
}

variable "force_delete" {
  description = "Determines if it has to be force deleted"
  default     = null
  type        = bool
}
variable "endpoint_type" {
  description = "Endpoint type of the Key"
  type        = string
  default     = null
}

variable "encrypted_nonce" {
  description = "Encrypted_nonce of the Key. Only for imported root key"
  type        = string
  default     = null
}

variable "iv_value" {
  description = "Iv_value of the Key. Only for imported root key"
  type        = string
  default     = null
}
variable "key_material" {
  description = "key_material of the Key"
  type        = string
  default     = null
}

variable "expiration_date" {
  description = "Expiration_date of the Key"
  type        = string
  default     = null
}

# HPCS policies 
variable "allowed_network_type" {
  description = "The network access policy to apply to your Hyper Protect Crypto Services instance. Acceptable values are public-and-private or private-only.After the network access policy is set to private-only, you cannot access your instance from the public network and cannot view or manage keys through the UI. However, you can still adjust the network setting later using the API or CLI"
  default     = "public-and-private"
  type        = string
}

variable "hpcs_port" {
  description = "HPCS service port"
  type        = number
}

variable "dual_auth_deletion_enabled" {
  description = "Dual auth deletion policy enabled or not"
  default     = true
  type        = bool
}

variable "initialize" {
  type        = bool
  description = "Flag indicating that if user want to initialize the hpcs instance. If 'true' then the instance is expected to initialize."
  default     = false
}
