resource "volterra_http_loadbalancer" "recommendations" {
  name      = "${var.environment}-recommendations"
  namespace = var.environment

  domains = ["recommendations.${var.environment}.buytime.internal"]

  http {
    dns_volterra_managed = false
    port                 = "80"
  }

  default_route_pools {
    pool {
      name      = volterra_origin_pool.recommendations.name
      namespace = var.environment
    }
    priority = 1
    weight   = 1
  }

  advertise_custom {
    advertise_where {
      site {
        site {
          name      = var.app_stack_name
          namespace = "system"
        }
      }
    }
  }

  disable_api_definition           = true
  disable_api_discovery            = true
  no_challenge                     = true
  disable_ddos_detection           = true
  source_ip_stickiness             = true
  disable_malicious_user_detection = true
  disable_rate_limit               = true
  service_policies_from_namespace  = true
  disable_trust_client_ip_headers  = true
  user_id_client_ip                = true
  disable_waf                      = true
}

resource "volterra_origin_pool" "recommendations" {
  name      = "${var.environment}-recommendations-pool"
  namespace = var.environment

  origin_servers {
    public_name {
      dns_name = "recommendations.buytime.sr.f5-cloud-demo.com"
    }
  }

  use_tls {
    tls_config {
      default_security = true
    }
  }
  port                   = 443
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}