terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "=0.11.44"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.39.0"
    }
    azuread = {
    source  = "hashicorp/azuread"
    version = "=3.5.0"
    }
  }
}

provider "volterra" {
  api_p12_file = var.xc_api_p12_file
  url          = var.xc_api_url
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_subscription_tenant_id
}

provider "azuread" {
  tenant_id = var.azure_subscription_tenant_id
}