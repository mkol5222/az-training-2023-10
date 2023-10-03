variable "cp_user" {
  type = string
  default = "api_user"
}

variable "cp_pass" {
  type = string
  default = "Vpn123Vpn123#nok"
}

variable "cp_server" {
  type = string
}


variable "install_target" {
  type        = string
  description = "name of TARGET object for policy installation"
  default = "chkp-standalone"
}

variable "package_name" {
  type        = string
  description = "name of package to install"
  default = "TerraformPolicyDemo"
}