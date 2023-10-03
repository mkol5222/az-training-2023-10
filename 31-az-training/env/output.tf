output "linux-subnet-id" {
    value = azurerm_subnet.linux-subnet.id
}

output "cp_back_subnet_id" {
    value = azurerm_subnet.cp-back.id
}


output "aks_subnet_id" {
    value = azurerm_subnet.aks-subnet.id
}

output "cp_front_subnet_id" {
    value = azurerm_subnet.cp-front.id
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "virtual_network_name" {
  value = var.virtual_network_name
}