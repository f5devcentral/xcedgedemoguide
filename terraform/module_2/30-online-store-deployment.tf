locals {
  online_store_contents = replace(file("${path.module}/../../deployments/ce-vk8s-online-store.yaml"), "online-store.f5-cloud-demo.com", var.user_domain)
  online_store          = split("\n---\n", local.online_store_contents)
}

resource "kubectl_manifest" "online_store" {
  count     = length(local.online_store)
  yaml_body = local.online_store[count.index]
}