provider "azurerm" {
  features {}

  # client_secret   = var.client_secret
  # client_id       = var.client_id
  # tenant_id       = var.tenant_id
  # subscription_id = var.subscription_id
}



terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.68.0" # "3.47.0"
    }

  }
}