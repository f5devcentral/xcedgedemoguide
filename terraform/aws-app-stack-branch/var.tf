variable "environment" {
  default     = "branch-a"
  description = "Environment Name"
  type        = string
}

variable "xc_api_url" {
  type    = string
  default = "https://your_tenant_name.console.ves.volterra.io/api"
}

variable "xc_api_p12_file" {
  default = "../api-creds.p12"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_access_key" {
  type    = string
  default = "your_aws_access_key"
}

variable "aws_secret_key" {
  type    = string
  default = "your_aws_secret_key"
}