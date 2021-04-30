#########################################################################################
# IBM Cloud Hyper Protect Crypto Services Provisioning, Initialization and Managing Keys
# Copyright 2020 IBM
#########################################################################################
variable "instance_id" {
  description = "ID of Service Instance"
  type        = string

}
variable "name" {
  description = "Name of the Key"
  type        = string
}
variable "endpoint_type" {
  description = "Endpoint type of the Key"
  type        = string
  default     = "public"
}
variable "encrypted_nonce" {
  description = "Encrypted_nonce of the Key"
  type        = string
  default     = null
}
variable "iv_value" {
  description = "Iv_value of the Key"
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

variable "interval_month" {
  description = "Specifies the key rotation time interval in months, with a minimum of 1, and a maximum of 12"
  type        = number
  default     = 3
}

variable "dual_auth_enabled" {
  description = "If set to true, Key Protect enables a dual authorization policy on a single key."
  type        = bool
  default     = false
}
