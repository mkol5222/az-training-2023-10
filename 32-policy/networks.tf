resource "checkpoint_management_network" "net-linux" {     
    broadcast    = "allow"
    color        = "blue"
    mask_length4 = 24
    name         = "net-linux"
    nat_settings = {
        "auto_rule"   = "true"
        "hide_behind" = "gateway"
        "install_on"  = "All"
        "method"      = "hide"
    }
    subnet4      = "10.42.5.0"
    tags         = []
}

resource "checkpoint_management_network" "net-aks" {     
    broadcast    = "allow"
    color        = "blue"
    mask_length4 = 24
    name         = "net-aks"
    nat_settings = {
        "auto_rule"   = "true"
        "hide_behind" = "gateway"
        "install_on"  = "All"
        "method"      = "hide"
    }
    subnet4      = "10.42.1.0"
    tags         = []
}

resource "checkpoint_management_network" "net-vnet42" {     
    broadcast    = "allow"
    color        = "blue"
    mask_length4 = 16
    name         = "net-vnet42"
    nat_settings = {
        "auto_rule"   = "true"
        "hide_behind" = "gateway"
        "install_on"  = "All"
        "method"      = "hide"
    }
    subnet4      = "10.42.0.0"
    tags         = []
}