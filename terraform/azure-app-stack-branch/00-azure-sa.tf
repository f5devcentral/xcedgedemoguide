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
        "Microsoft.Authorization/roleAssignments/*",
        "Microsoft.Compute/disks/delete",
        "Microsoft.Compute/virtualMachineScaleSets/delete",
        "Microsoft.Compute/virtualMachineScaleSets/write",
        "Microsoft.Compute/virtualMachines/delete",
        "Microsoft.Compute/virtualMachines/write",
        "Microsoft.Marketplace/offerTypes/publishers/offers/plans/agreements/*",
        "Microsoft.MarketplaceOrdering/agreements/offers/plans/cancel/action",
        "Microsoft.MarketplaceOrdering/offerTypes/publishers/offers/plans/agreements/write",
        "Microsoft.Network/loadBalancers/*",
        "Microsoft.Network/locations/setLoadBalancerFrontendPublicIpAddresses/action",
        "Microsoft.Network/networkInterfaces/*",
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
        "Microsoft.Network/virtualNetworks/subnets/*",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write",
        "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete",
        "Microsoft.Network/virtualNetworks/write",
        "Microsoft.Network/virtualNetworkGateways/delete",
        "Microsoft.Network/virtualNetworkGateways/read",
        "Microsoft.Network/virtualNetworkGateways/write",
        "Microsoft.Resources/subscriptions/resourcegroups/*"
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
  application_id = azuread_application.auth.application_id
  owners = [
    data.azuread_client_config.current.object_id,
  ]
}

resource "azuread_service_principal_password" "auth" {
  service_principal_id = azuread_service_principal.auth.id
  end_date_relative    = "240h"
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "auth" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.auth.role_definition_resource_id
  principal_id       = azuread_service_principal.auth.id

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
  value       = azuread_application.auth.application_id
  description = "applicaiton id"
}