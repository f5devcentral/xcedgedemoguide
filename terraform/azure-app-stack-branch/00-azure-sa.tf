resource "azurerm_resource_group" "rg" {
  name     = var.environment
  location = var.azure_rg_location
}

resource "azurerm_role_definition" "auth" {
  name        = "${var.environment}-role"
  scope       = data.azurerm_subscription.primary.id
  description = "F5XC Custom Role to integrate Azure with XC Cloud"

  permissions {
    actions = [
        "*/read",
        "*/register/action",
        "Microsoft.Compute/disks/delete",
        "Microsoft.Compute/skus/read",
        "Microsoft.Compute/virtualMachineScaleSets/delete",
        "Microsoft.Compute/virtualMachineScaleSets/write",
        "Microsoft.Compute/virtualMachines/delete",
        "Microsoft.Compute/virtualMachines/write",
        "Microsoft.MarketplaceOrdering/agreements/offers/plans/cancel/action",
        "Microsoft.MarketplaceOrdering/offerTypes/publishers/offers/plans/agreements/write",
        "Microsoft.Network/loadBalancers/backendAddressPools/delete",
        "Microsoft.Network/loadBalancers/backendAddressPools/join/action",
        "Microsoft.Network/loadBalancers/backendAddressPools/write",
        "Microsoft.Network/loadBalancers/delete",
        "Microsoft.Network/loadBalancers/write",
        "Microsoft.Network/locations/setLoadBalancerFrontendPublicIpAddresses/action",
        "Microsoft.Network/networkInterfaces/delete",
        "Microsoft.Network/networkInterfaces/join/action",
        "Microsoft.Network/networkInterfaces/write",
        "Microsoft.Network/networkSecurityGroups/delete",
        "Microsoft.Network/networkSecurityGroups/join/action",
        "Microsoft.Network/networkSecurityGroups/securityRules/delete",
        "Microsoft.Network/networkSecurityGroups/securityRules/write",
        "Microsoft.Network/networkSecurityGroups/write",
        "Microsoft.Network/publicIPAddresses/delete",
        "Microsoft.Network/publicIPAddresses/join/action",
        "Microsoft.Network/publicIPAddresses/write",
        "Microsoft.Network/routeTables/delete",
        "Microsoft.Network/routeTables/join/action",
        "Microsoft.Network/routeTables/write",
        "Microsoft.Network/virtualHubs/delete",
        "Microsoft.Network/virtualHubs/bgpConnections/delete",
        "Microsoft.Network/virtualHubs/bgpConnections/read",
        "Microsoft.Network/virtualHubs/bgpConnections/write",
        "Microsoft.Network/virtualHubs/ipConfigurations/delete",
        "Microsoft.Network/virtualHubs/ipConfigurations/read",
        "Microsoft.Network/virtualHubs/ipConfigurations/write",
        "Microsoft.Network/virtualHubs/read",
        "Microsoft.Network/virtualHubs/write",
        "Microsoft.Network/virtualNetworks/delete",
        "Microsoft.Network/virtualNetworks/peer/action",
        "Microsoft.Network/virtualNetworks/subnets/delete",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/read",
        "Microsoft.Network/virtualNetworks/subnets/write",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
        "Microsoft.Network/virtualNetworks/write",
        "Microsoft.Network/virtualNetworkGateways/delete",
        "Microsoft.Network/virtualNetworkGateways/read",
        "Microsoft.Network/virtualNetworkGateways/write",
        "Microsoft.Resources/subscriptions/locations/read",
        "Microsoft.Resources/subscriptions/resourcegroups/delete",
        "Microsoft.Resources/subscriptions/resourcegroups/read",
        "Microsoft.Resources/subscriptions/resourcegroups/write",
        "Microsoft.Compute/virtualMachines/extensions/write",
        "Microsoft.Compute/virtualMachines/extensions/delete"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

resource "azuread_application" "auth" {
  display_name = "${var.environment}-app"
  owners = [
    data.azuread_client_config.current.object_id,
  ]
}

resource "azuread_service_principal" "auth" {
  client_id = azuread_application.auth.client_id
  owners = [
    data.azuread_client_config.current.object_id,
  ]
}

resource "azuread_service_principal_password" "auth" {
  service_principal_id = azuread_service_principal.auth.id
  end_date             = timeadd(timestamp(), "240h")
  lifecycle {
    ignore_changes = [end_date]
  }
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "auth" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.auth.role_definition_resource_id
  principal_id       = azuread_service_principal.auth.object_id

  depends_on = [ 
    azuread_application.auth
   ]
}

output "subscription_id" {
  value       = var.azure_subscription_id
  description = "subscription"
}

output "tenant" {
  value       = var.azure_subscription_tenant_id
  description = "tenant"
}

output "service_principal_password" {
  value       = azuread_service_principal_password.auth.value
  description = "service principal password"
  sensitive   = true
}

output "application_id" {
  value       = azuread_application.auth.client_id
  description = "applicaiton id"
}