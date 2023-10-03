data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "http" "myip" {
  url = "http://ip.iol.cz/ip/"
}

output "myip" {
  value = data.http.myip.response_body
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.42.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_subnet" "linux-subnet" {
  name                 = "linux-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.5.0/24"]
}

resource "azurerm_subnet" "aks-subnet" {
  name                 = "aks-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.1.0/24"]
}

resource "azurerm_subnet" "cp-back" {
  name                 = "cp-back-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.4.0/24"]
}

resource "azurerm_subnet" "cp-front" {
  name                 = "cp-front-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.3.0/24"]
}


resource "azurerm_route_table" "linux-rt" {
  name                          = "linux-rt-tf"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

#   route {
#     name                   = "to-aks1"
#     address_prefix         = "10.42.1.0/24"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.42.4.4"
#   }
#   route {
#     name                   = "to-internet"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.42.4.47"
#   }
route {
    name                   = "to-aks"
    address_prefix         = "10.42.1.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.42.4.4"
  }
  route {
    name           = "route-to-my-pub-ip"
    address_prefix = "${data.http.myip.response_body}/32"
    next_hop_type  = "Internet"
  }
   dynamic "route" {
    for_each = var.route_through_firewall ? [] : [1]
    content {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
     }
   }
  dynamic "route" {
    for_each = var.route_through_firewall ? [1] : []
    content {
      name                   = "to-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.42.4.4"
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

}

resource "azurerm_subnet_route_table_association" "linux-rt-to-subnet" {
  subnet_id      = azurerm_subnet.linux-subnet.id
  route_table_id = azurerm_route_table.linux-rt.id
}

resource "azurerm_route_table" "aks-rt" {
  name                          = "aks-rt-tf"
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false


  route {
    name                   = "to-linux"
    address_prefix         = "10.42.5.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.42.4.4"
  }
    route {
    name           = "route-to-my-pub-ip"
    address_prefix = "${data.http.myip.response_body}/32"
    next_hop_type  = "Internet"
  }
   dynamic "route" {
    for_each = var.route_through_firewall ? [] : [1]
    content {
    name                   = "to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
     }
   }
  dynamic "route" {
    for_each = var.route_through_firewall ? [1] : []
    content {
      name                   = "to-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.42.4.4"
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_subnet_route_table_association" "aks-rt-to-subnet" {
  subnet_id      = azurerm_subnet.aks-subnet.id
  route_table_id = azurerm_route_table.aks-rt.id
}



variable "virtual_network_name" {
  default = "vnet1"
}