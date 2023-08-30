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
  type    = string
  default = "../api-creds.p12"
}

variable "kubeconfig_path" {
  type    = string
  default = "../kubeconfig_mk8s.yaml"
}

variable "app_stack_name" {
  type        = string
  default     = "azure-branch-a"
  description = "App Stack Name"
}