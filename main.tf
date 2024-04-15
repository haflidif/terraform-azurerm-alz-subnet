# Creating a resource group for the subnet sub resources, NSG and Route Tables if it's not referenced by input variable
resource "azurerm_resource_group" "sub_resouces_rg" {
  count    = ((var.create_network_security_group || var.create_route_table) && var.use_existing_resource_group == false) ? 1 : 0
  name     = var.sub_resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    precondition {
      condition     = var.sub_resource_group_name != "" && var.create_network_security_group == true || var.create_route_table == true
      error_message = "Please pass in a value for sub_resource_group_name, or set either var.create_network_security_group or var.create_route_table to false and provide a value for network_security_group_id or route_table_id to reference an existing network security group or route table."
    }
  }
}

# Creating a network security group for the subnet if it's not referenced by input variable.check.
resource "azurerm_network_security_group" "nsg" {
  count               = var.create_network_security_group ? 1 : 0
  name                = var.network_security_group_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  depends_on = [azurerm_resource_group.sub_resouces_rg]

  lifecycle {
    precondition {
      condition     = var.network_security_group_name != "" && var.create_network_security_group == true
      error_message = "Please pass in a value for network_security_group_name, or set create_network_security_group to false and provide a value for network_security_group_id to reference an existing network security group."
    }
  }
}

# Creating a route table for the subnet if it's not referenced by input variable.
resource "azurerm_route_table" "route_table" {
  count                         = var.create_route_table ? 1 : 0
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = local.resource_group_name
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  tags = var.tags

  depends_on = [azurerm_resource_group.sub_resouces_rg]

  lifecycle {
    precondition {
      condition     = var.route_table_name != "" && var.create_route_table == true
      error_message = "Please pass in a value for route_table_name, or set create_sub_network_resources to false and provide a value for route_table_id to reference an existing route table."
    }
  }
}

# Creating default route to network virtual appliance with in the new route table if var.nva_ip_address is not empty string, this is used to route traffic to a network virtual appliance, often a firewall that is located in a hub virtual network.
resource "azurerm_route" "default_route_to_nva" {
  count                  = var.nva_ip_address != "" ? 1 : 0
  name                   = "default-route-to-nva"
  resource_group_name    = local.resource_group_name
  route_table_name       = azurerm_route_table.route_table[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.nva_ip_address
}

# Creating the subnet by using the azapi_resource.
resource "azapi_resource" "subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2023-04-01"
  name      = var.subnet_name
  parent_id = var.virtual_network_resource_id

  body = jsonencode({
    properties = {

      # List of Address prefixes in the subnet.
      addressPrefixes = var.address_prefixes

      # Service delegations for the subnet.
      delegations = var.delegation_service_name != "" ? local.delegations : []

      # Service Endpoints for the subnet.
      serviceEndpoints = length(var.service_endpoint_names) != 0 ? local.serviceEndpoints : []

      privateEndpointNetworkPolicies    = lookup(local.private_link_and_endpoint_network_policies_enabled_map, var.private_endpoint_network_policies_enabled)
      privateLinkServiceNetworkPolicies = lookup(local.private_link_and_endpoint_network_policies_enabled_map, var.private_link_service_network_policies_enabled)

      # Conditionally include networkSecurityGroup
      networkSecurityGroup = var.network_security_group_id != "" || local.created_network_security_group_id != "" ? {
        id = try(coalesce(var.network_security_group_id, local.created_network_security_group_id), "")
      } : null

      # Conditionally include routeTable
      routeTable = var.route_table_id != "" || local.created_route_table_id != "" ? {
        id = try(coalesce(var.route_table_id, local.created_route_table_id), "")
      } : null

    }
  })
}
