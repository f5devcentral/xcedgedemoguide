resource "volterra_virtual_site" "buytime_re" {
  name      = "buytime-re-sites"
  namespace = volterra_namespace.buytime.name

  site_selector {
    expressions = ["ves.io/region in (ves-io-seattle, ves-io-singapore, ves-io-stockholm)"]
  }

  site_type = "REGIONAL_EDGE"

  depends_on = [ 
    volterra_namespace.buytime
   ]
}

resource "volterra_virtual_site" "buytime_ce" {
  name      = "buytime-ce-sites"
  namespace = volterra_namespace.buytime.name

  site_selector {
    expressions = ["location in (buytime-ce-site)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [ 
    volterra_namespace.buytime
   ]
}

resource "volterra_virtual_k8s" "buytime" {
  name      = "buytime-online-vk8s"
  namespace = volterra_namespace.buytime.name
  vsite_refs {
    name = volterra_virtual_site.buytime_ce.name
  }
    
  vsite_refs {
    name = volterra_virtual_site.buytime_re.name
  }
}

resource "volterra_api_credential" "buytime" {
  created_at = timestamp()
  name                  = "buytime-online-kubeconfig"
  api_credential_type   = "KUBE_CONFIG"
  virtual_k8s_namespace = volterra_namespace.buytime.name
  virtual_k8s_name      = volterra_virtual_k8s.buytime.name
}

resource "local_file" "kubeconfig" {
  content_base64 = volterra_api_credential.buytime.data
  filename       = "${var.kubeconfig_path}"
}

output "kubecofnig_path" {
 value       = "${var.kubeconfig_path}"
 sensitive   = false
 description = "Kubeconfig path"
 depends_on  = [ local_file.kubeconfig ]
}