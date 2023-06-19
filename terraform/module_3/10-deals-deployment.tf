locals {
  deals_module_contents = file("${path.module}/../../deployments/re-vk8s-deals.yaml")
  deals_module          = split("\n---\n", local.deals_module_contents)
}

resource "kubectl_manifest" "deals_module" {
  count     = length(local.deals_module)
  yaml_body = local.deals_module[count.index]
}