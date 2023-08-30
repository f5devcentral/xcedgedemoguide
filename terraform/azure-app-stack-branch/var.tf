variable "environment" {
  type        = string
  default     = "branch-a"
  description = "Environment Name"
}

variable "xc_api_url" {
  type    = string
  default = "https://your_tenant_name.console.ves.volterra.io/api"
}

variable "xc_api_p12_file" {
  default = "../api-creds.p12"
}

variable "azure_rg_location" {
  type    = string
  default = "eastus2"
}

variable "azure_subscription_id" {
  type    = string
  default = "your_azure_subscription_id"
}

variable "azure_subscription_tenant_id" {
  type    = string
  default = "your_azure_tenant_id"
}

variable "azure_xc_machine_type" {
  type    = string
  default = "Standard_D3_v2"
}
