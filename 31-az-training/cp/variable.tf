variable "sg_name" {
  type        = string
  description = "Check Point SG(standalone) name"
  default     = "chkp"
}

variable "vm_os_sku" {
  /*
    Choose from:
      - "sg-byol"
      - "sg-ngtp-v2" (for R80.30 only)
      - "sg-ngtx-v2" (for R80.30 only)
      - "sg-ngtp" (for R80.40 and above)
      - "sg-ngtx" (for R80.40 and above)
      - "mgmt-byol"
      - "mgmt-25"
  */
  description = "The sku of the image to be deployed"
  type        = string
  default     = "mgmt-byol"
}
variable "vm_os_offer" {
  description = "The name of the image offer to be deployed.Choose from: check-point-cg-r8030, check-point-cg-r8040, check-point-cg-r81"
  type        = string
  default     = "check-point-cg-r8110"
}
variable "publisher" {
  description = "CheckPoint publicher"
  default     = "checkpoint"
}

variable "resource_group_name" {
  description = "Resource Group for network environment"
  type        = string
  default     = "tf-azure-training-rg"
}

variable "admin_username" {
  description = "Administrator username of deployed VM. Due to Azure limitations 'notused' name can be used"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Administrator password of deployed Virtual Macine. The password must meet the complexity requirements of Azure"
  type        = string
}



variable "vnet_allocation_method" {
  description = "IP address allocation method"
  type        = string
  default     = "Static"
}

variable "cp_front_subnet_id" {
  description = "Subnet ID for Check Point Frontend"
  type        = string
}


variable "cp_back_subnet_id" {
  description = "Subnet ID for Check Point Backend"
  type        = string
}

// bootdiag storage
variable "storage_account_tier" {
  description = "Defines the Tier to use for this storage account.Valid options are Standard and Premium"
  default     = "Standard"
}
variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account.Valid options are LRS, GRS, RAGRS and ZRS"
  type        = string
  default     = "LRS"
}


// VM
variable "vm_size" {
  description = "Specifies size of Virtual Machine"
  type        = string
  default = "Standard_D3_v2"
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when VM is terminated"
  default     = true
}

variable "installation_type" {
  description = "Installaiton type. Allowed values: standalone, gateway, custom"
  type        = string
  default     = "standalone"
}
variable "allow_upload_download" {
  description = "Allow upload/download to Check Point"
  type        = bool
  default     = true
}
variable "os_version" {
  description = "GAIA OS version"
  type        = string
  default            = "R81.10"
}

variable "template_name" {
  description = "Template name. Should be defined according to deployment type(mgmt, ha, vmss)"
  type        = string
  default     = "single_terraform"
}

variable "template_version" {
  description = "Template version. It is reccomended to always use the latest template version"
  type        = string
  default     = "20210126"
}
variable "bootstrap_script" {
  description = "An optional script to run on the initial boot"
  type        = string
  default     = ""
}
variable "is_blink" {
  description = "Define if blink image is used for deployment"
  type        = bool
  default     = false
}
variable "sic_key" {
  description = "Secure Internal Communication(SIC) key"
  type        = string
}
variable "management_GUI_client_network" {
  description = "Allowed GUI clients - GUI clients network CIDR"
  type        = string
}
variable "enable_custom_metrics" {
  description = "Indicates whether CloudGuard Metrics will be use for Cluster members monitoring."
  type        = bool
  default     = false
}

variable "authentication_type" {
  description = "Specifies whether a password authentication or SSH Public Key authentication should be used"
  type        = string
}
locals { // locals for 'authentication_type' allowed values
  authentication_type_allowed_values = [
    "Password",
    "SSH Public Key"
  ]
  // will fail if [var.authentication_type] is invalid:
  validate_authentication_type_value = index(local.authentication_type_allowed_values, var.authentication_type)
}


variable "disk_size" {
  description = "Storage data disk size size(GB).Select a number between 100 and 3995"
  type        = string
  default     = 110
}
variable "storage_os_disk_create_option" {
  description = "The method to use when creating the managed disk"
  type        = string
  default     = "FromImage"
}

variable "storage_os_disk_caching" {
  description = "Specifies the caching requirements for the OS Disk"
  default     = "ReadWrite"
}

variable "managed_disk_type" {
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS"
  type        = string
  default     = "Standard_LRS"
}
variable "vm_os_version" {
  description = "The version of the image that you want to deploy. "
  type        = string
  default     = "latest"
}
variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options is Standard_LRS, Premium_LRS"
  type        = string
  default     = "Standard_LRS"
}

