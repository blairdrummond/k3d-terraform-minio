terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.98.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.4.1"
    }
  }
}

#provider "azurerm" {
#  features {}
#}
