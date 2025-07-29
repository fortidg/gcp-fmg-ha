variable "project" {}
variable "region" {}
variable "zone" {}
variable "zone2" {}

variable "prefix" {}

# FortiGates
variable "fortimanager_machine_type" {}
variable "fortimanager_vm_image" {}

variable "fmg_password" {
  type        = string
  default     = "Fortinet1234$"
  description = "FortiManager Password"
}

# debug
variable "enable_output" {
  type        = bool
  default     = true
  description = "Debug"
}

variable "flex_tokens" {
  type        = list(string)
  default     = ["", ""]
  description = "List of FortiFlex tokens to be applied during bootstrapping"
}

variable "license_type" {
  type        = string
  default     = "flex"
  description = "License type: flex, payg or byol"
}

variable "fortimanager_license_files" {}

variable "fmg_username" {
  type        = string
  default     = "fortinet"
  description = "FortiManager Username"
}