terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
  }
  storage_use_azuread = true
}
