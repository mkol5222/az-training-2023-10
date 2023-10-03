provider "checkpoint" {
  # Configuration options
  server   = var.cp_server
  username = var.cp_user
  password = var.cp_pass
  context  = "web_api"
  session_name = "TF session"
}

terraform {
  required_providers {

     checkpoint = {
      source = "CheckPointSW/checkpoint"
      version = "2.3.0"
      #version = "2.2.0"
    }
  }
}