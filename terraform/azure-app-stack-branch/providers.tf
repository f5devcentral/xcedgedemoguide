terraform {
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "=0.11.25"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.69.0"
    }
    azuread = {
    source  = "hashicorp/azuread"
    version = "=2.41.0"
    }
  }
}

provider "volterra" {
  api_p12_file = var.xc_api_p12_file
  url          = var.xc_api_url
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_subscription_tenant_id
}

provider "azuread" {
  tenant_id = var.azure_subscription_tenant_id
}