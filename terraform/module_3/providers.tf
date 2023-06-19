terraform {
  required_version = ">= 1.4.0"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "=0.11.23"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "=1.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "=2.4.0"
    }
  }
}

provider "kubectl" {
  config_path = var.kubeconfig_path
}

provider "volterra" {
  api_p12_file = var.xc_api_p12_file
  url          = var.xc_api_url
}