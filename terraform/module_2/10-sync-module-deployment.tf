locals {
  sync_module_contents = file("${path.module}/../../deployments/ce-vk8s-inventory-server.yaml")
  sync_module          = split("\n---\n", local.sync_module_contents)
}

resource "kubectl_manifest" "sync_module" {
  count     = length(local.sync_module)
  yaml_body = local.sync_module[count.index]
}