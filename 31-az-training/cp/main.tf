
# accept offering
# resource "azurerm_marketplace_agreement" "checkpoint" {
#   count     = 1
#   publisher = var.publisher   //"checkpoint"
#   offer     = var.vm_os_offer //"check-point-cg-r8110" // vm_os_offer           = "check-point-cg-r8110"                 # "check-point-cg-r8040"
#   plan      = var.vm_os_sku   // "mgmt-byol"             // vm_os_sku             = "mgmt-byol"                              # "mgmt-byol" or "sg-byol" 
# }

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    # resource_group = data.azurerm_resource_group.rg.name
    sg_name = var.sg_name
  }

  byte_length = 8
}

//
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# CHKP public IP
resource "azurerm_public_ip" "public-ip" {
  name                    = var.sg_name
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  allocation_method       = var.vnet_allocation_method
  idle_timeout_in_minutes = 30
  domain_name_label = join("", [
    var.sg_name,
    "-",
  random_id.randomId.hex])

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# external NIC
resource "azurerm_network_interface" "nic1" {
  depends_on = [
  azurerm_public_ip.public-ip]
  name                          = "eth0"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.cp_front_subnet_id
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address            = "10.42.3.4" //cidrhost(var.subnet_prefixes[0], 4)
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# internal NIC
resource "azurerm_network_interface" "nic2" {

  name                          = "eth1"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = var.cp_back_subnet_id
    private_ip_address_allocation = var.vnet_allocation_method
    private_ip_address            = "10.42.4.4" //cidrhost(azurerm_subnet.cp-back.subnet_prefixes[0], 4)
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# resource "random_id" "randomId" {
#   keepers = {
#     # Generate a new ID only when a new resource group is defined
#     resource_group = azurerm_resource_group.rg.name
#   }
#   byte_length = 8
# }
resource "azurerm_storage_account" "vm-boot-diagnostics-storage" {
  name                     = "bootdiag${random_id.randomId.hex}"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.account_replication_type
  account_kind             = "Storage"

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

locals {
  SSH_authentication_type_condition = var.authentication_type == "SSH Public Key" ? true : false
  // custom_image_condition            = var.source_image_vhd_uri == "noCustomUri" ? false : true
}

resource "azurerm_virtual_machine" "sg-vm-instance" {
  depends_on = [
    //azurerm_marketplace_agreement.checkpoint,
    azurerm_network_interface.nic1,
    azurerm_network_interface.nic2
  ]

  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  name = var.sg_name

  network_interface_ids = [
    azurerm_network_interface.nic1.id,
    azurerm_network_interface.nic2.id
  ]


  vm_size                       = var.vm_size

  delete_os_disk_on_termination = var.delete_os_disk_on_termination

  primary_network_interface_id  = azurerm_network_interface.nic1.id

  #   identity {
  #     type = module.common.vm_instance_identity
  #   }

  plan {

    name      = var.vm_os_sku
    publisher = var.publisher
    product   = var.vm_os_offer
  }


  boot_diagnostics {
    enabled     = true
    storage_uri = join(",", azurerm_storage_account.vm-boot-diagnostics-storage.*.primary_blob_endpoint)
  }

  os_profile {
    computer_name  = var.sg_name
    admin_username = var.admin_username
    admin_password = var.admin_password

    custom_data = templatefile("${path.module}/cloud-init.sh", {
      installation_type             = var.installation_type
      allow_upload_download         = var.allow_upload_download
      os_version                    = var.os_version
      template_name                 = var.template_name
      template_version              = var.template_version
      is_blink                      = var.is_blink
      bootstrap_script64            = base64encode(var.bootstrap_script)
      location                      = data.azurerm_resource_group.rg.location
      sic_key                       = var.sic_key
      management_GUI_client_network = var.management_GUI_client_network
      enable_custom_metrics         = var.enable_custom_metrics ? "yes" : "no"
    })
  }
  os_profile_linux_config {
    disable_password_authentication = local.SSH_authentication_type_condition

    dynamic "ssh_keys" {
      for_each = local.SSH_authentication_type_condition ? [
      1] : []
      content {
        path     = "/home/notused/.ssh/authorized_keys"
        key_data = file("${path.module}/azure_public_key")
      }
    }
  }

  storage_image_reference {
    id        = null          // local.custom_image_condition ? azurerm_image.custom-image[0].id : null
    publisher = var.publisher // local.custom_image_condition ? null : module.common.publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  storage_os_disk {
    name              = var.sg_name
    create_option     = var.storage_os_disk_create_option
    caching           = var.storage_os_disk_caching
    managed_disk_type = var.storage_account_type
    disk_size_gb      = var.disk_size
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}