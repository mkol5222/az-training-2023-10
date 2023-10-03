
resource "checkpoint_management_access_rule" "rule900" {
  layer    = "${checkpoint_management_package.TFdemo.name} Network"
  position = { top = "top" }
  name     = "Logger from VNET"
  source   = [checkpoint_management_network.net-vnet42.name]
  enabled            = true
  destination        = ["Any"]
  destination_negate = false
  service            = ["Any"]
  service_negate     = false
  action             = "Accept"
  action_settings = {
    enable_identity_captive_portal = false
  }
  track = {
    accounting              = false
    alert                   = "none"
    enable_firewall_session = true
    per_connection          = true
    per_session             = true
    type                    = "Log"
  }
}

resource "checkpoint_management_access_rule" "rule901" {
  layer    = "${checkpoint_management_package.TFdemo.name} Network"
   position = { below = checkpoint_management_access_rule.rule900.id }
  name     = "Logger to VNET"
  source   = ["Any"]
  enabled            = true
  destination        = [checkpoint_management_network.net-vnet42.name]
  destination_negate = false
  service            = ["Any"]
  service_negate     = false
  action             = "Accept"
  action_settings = {
    enable_identity_captive_portal = false
  }
  track = {
    accounting              = false
    alert                   = "none"
    enable_firewall_session = true
    per_connection          = true
    per_session             = true
    type                    = "Log"
  }
}