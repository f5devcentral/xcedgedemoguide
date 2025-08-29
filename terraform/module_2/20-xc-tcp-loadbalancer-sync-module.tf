resource "volterra_tcp_loadbalancer" "sync_module" {
  name      = "inventory-server-branches"
  namespace = var.environment

  origin_pools_weights {
    pool {
      name = volterra_origin_pool.sync_module.name
    }
  }

  domains     = ["inventory-server.branches.buytime.internal"]
  listen_port = 3000

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

  retract_cluster                 = true
  hash_policy_choice_round_robin  = true
  tcp                             = true
  service_policies_from_namespace = true
  no_sni                          = true
}

resource "volterra_origin_pool" "sync_module" {
  name      = "inventory-server-branches-pool"
  namespace = var.environment

  origin_servers {
    k8s_service {
      service_name = "inventory-server-service.${var.environment}"
      site_locator {
        virtual_site {
          name = "buytime-ce-sites"
        }
      }
      vk8s_networks = true
    }
  }

  no_tls                 = true
  port                   = 3000
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}