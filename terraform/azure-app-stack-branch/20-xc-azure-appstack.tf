resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "volterra_cloud_credentials" "azure_cred" {
  name      = "azure-${var.environment}"
  namespace = "system"
  azure_client_secret {
    client_id = azuread_application.auth.application_id
    client_secret {
        clear_secret_info {
            url = "string:///${base64encode(azuread_service_principal_password.auth.value)}"
        }
    }
    subscription_id = var.azure_subscription_id
    tenant_id       = var.azure_subscription_tenant_id
  }

  depends_on = [ 
    azuread_service_principal_password.auth,
    azuread_application.auth,
    azurerm_role_assignment.auth
  ]
}

resource "volterra_azure_vnet_site" "appstack" {
  name       = "azure-${var.environment}"
  namespace  = "system"
  azure_region             = azurerm_resource_group.rg.location
  resource_group           = "${azurerm_resource_group.rg.name}-xc"
  logs_streaming_disabled  = true
  machine_type             = var.azure_xc_machine_type
  ssh_key                  = tls_private_key.key.public_key_openssh
  no_worker_nodes          = true


  blocked_services {
    blocked_sevice {
      dns = false
    }
  }

  azure_cred {
    name      = volterra_cloud_credentials.azure_cred.name
    namespace = "system"
  }

  voltstack_cluster {
    azure_certified_hw       = "azure-byol-voltstack-combo"
    no_dc_cluster_group      = true
    no_forward_proxy         = true
    no_global_network        = true
    no_k8s_cluster           = true
    no_network_policy        = true
    no_outside_static_routes = true
    sm_connection_public_ip  = true
    default_storage          = true

    az_nodes {
      azure_az  = "1"
      disk_size = "80"

      local_subnet {
        subnet {
          subnet_name         = azurerm_subnet.subnet_a.name
          vnet_resource_group = true
        }
      }
    }

    k8s_cluster {
      name = volterra_k8s_cluster.mk8s.name
    }
  }

  vnet {
    existing_vnet {
        resource_group = azurerm_resource_group.rg.name
        vnet_name      = azurerm_virtual_network.vnet.name
    }
  }

  lifecycle {
    ignore_changes = [labels]
  }

  depends_on = [
    volterra_cloud_credentials.azure_cred,
    azurerm_virtual_network.vnet,
    azurerm_subnet.subnet_a,
    azurerm_role_definition.auth
  ]
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_azure_vnet_site.appstack.name
  site_type        = "azure_vnet_site"
  ignore_on_delete = true

  labels           = {
    location = "buytime-app-stack"
  }
}

resource "volterra_tf_params_action" "action_apply" {
  site_name        = volterra_azure_vnet_site.appstack.name
  site_kind        = "azure_vnet_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = true

  depends_on = [
    volterra_azure_vnet_site.appstack,
  ]
}

data "azurerm_network_interface" "xc_nic" {
  name                = "master-0-slo"
  resource_group_name = "${azurerm_resource_group.rg.name}-xc"
  depends_on = [
     volterra_tf_params_action.action_apply
  ]
}

output "appstack_private_ip" {
  value = data.azurerm_network_interface.xc_nic.private_ip_address
}

# resource "azurerm_route_table" "xc_routes" {
#   name                          = "xc-route-table"
#   location                      = azurerm_resource_group.rg.location
#   resource_group_name           = "${azurerm_resource_group.rg.name}-xc"
#   disable_bgp_route_propagation = false

#   route {
#     name                   = "remote-net"
#     address_prefix         = var.xc_remote_cidr
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = data.azurerm_network_interface.xc_private_nic.private_ip_address
#   }

#   depends_on = [
#     volterra_tf_params_action.action_apply
#   ]
# }

output "xc_private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "xc_public_key" {
  value = tls_private_key.key.public_key_openssh
}