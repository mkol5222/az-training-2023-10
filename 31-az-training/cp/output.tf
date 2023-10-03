output "cp-public-ip" {
  value = azurerm_public_ip.public-ip.ip_address
}
output "cp-pass" {
  sensitive = true
  value     = var.admin_password
}

output "sg_name" {
  value = var.sg_name
}

