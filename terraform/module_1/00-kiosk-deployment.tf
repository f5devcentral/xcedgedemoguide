locals {
  file_contents        = file("${path.module}/../../deployments/appstack-mk8s-kiosk.yaml")
  appstack_mk8s_kiosk  = split("\n---\n", local.file_contents)
}

resource "kubectl_manifest" "branch_a" {
  count     = length(local.appstack_mk8s_kiosk)
  yaml_body = local.appstack_mk8s_kiosk[count.index]
}