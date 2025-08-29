resource "volterra_http_loadbalancer" "kiosk" {
  name      = "${var.environment}-kiosk-internal"
  namespace = var.environment

  domains = ["kiosk.${var.environment}.buytime.internal"]

  http {
    dns_volterra_managed = false
    port                 = "80"
  }

  default_route_pools {
    pool {
      name      = volterra_origin_pool.branch_a.name
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
        network = "SITE_NETWORK_INSIDE_AND_OUTSIDE"
      }
    }
  }
  disable_api_definition           = true
  disable_api_discovery            = true
  no_challenge                     = true
  source_ip_stickiness             = true
  disable_malicious_user_detection = true
  disable_rate_limit               = true
  service_policies_from_namespace  = true
  disable_trust_client_ip_headers  = true
  user_id_client_ip                = true
  disable_waf                      = true
}

resource "volterra_origin_pool" "branch_a" {
  name      = "${var.environment}-kiosk-pool"
  namespace = var.environment

  origin_servers {
    k8s_service {
      service_name = "kiosk-service.${var.environment}"
      site_locator {
        site {
          name      = var.app_stack_name
          namespace = "system"
        }
      }
      vk8s_networks = true
    }
  }

  no_tls                 = true
  port                   = 8080
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}