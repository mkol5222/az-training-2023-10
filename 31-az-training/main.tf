module "env" {
    source = "./env"
    resource_group_name = var.rg
    route_through_firewall = var.route_through_firewall
}

module "standalone-chkp" {
  depends_on = [
    module.env.cp_back_subnet_id,
    module.env.cp_front_subnet_id
  ]
  sg_name                       = "chkp-standalone"
  source                        = "./cp"
  resource_group_name           = module.env.resource_group_name
  cp_back_subnet_id             = module.env.cp_back_subnet_id
  cp_front_subnet_id            = module.env.cp_front_subnet_id
  admin_username                = "guru"
  admin_password                = var.admin_password
  authentication_type           = "Password"
  sic_key                       = "Vpn123456!Vpn123456"
  management_GUI_client_network = "0.0.0.0/0"
  vm_size                       = "Standard_D3_v2"

}

module "ubuntu1" {
  depends_on = [
    module.env.linux-subnet-id
  ]
  source               = "./linux"

  resource_group_name  = module.env.resource_group_name
  linux-subnet-name    = "linux-subnet"
  virtual_network_name = module.env.virtual_network_name
  vm_name              = "ubuntu1"
}

output "ssh_key" {
    value = module.ubuntu1.ssh_key
    sensitive = true
}
output "ssh_key_pub" {
    value = module.ubuntu1.ssh_key_pub
    sensitive = true
}
output "ssh_config" {
    value = module.ubuntu1.ssh_config
}