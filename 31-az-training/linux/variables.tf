


variable "resource_group_name" {
  description = "Resource Group for network environment"
  type        = string
  default     = "tf-azure-training-rg"
}

variable "virtual_network_name" {
  type = string
}
variable "linux-subnet-name" {
  description = "value for the name of the linux subnet"
  type        = string
}

variable "vm_name" {
  description = "value for the name of the virtual machine"
  type        = string
}