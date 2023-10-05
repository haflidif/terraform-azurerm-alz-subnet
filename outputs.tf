# All outputs from the module should be defined here, e.g. if resource id of a resource created by this module is needed for other configurations.
# Outputs the subnet id.
output "subnet_id" {
  value       = azapi_resource.subnet.id
  description = "Virtual Network Subnet resource id"
}

# Outputs the Network Security Group Id if created by this module, otherwise it will output the id of the network security group referenced by the input variable.
output "subnet_nsg_id" {
  value       = coalesce(var.network_security_group_id, local.created_network_security_group_id)
  description = "Network Security Group resource id"
}

# Outputs the Route Table Id if created by this module, otherwise it will output the id of the route table referenced by the input variable.
output "subnet_route_table_id" {
  value       = coalesce(var.route_table_id, local.created_route_table_id)
  description = "Route Table resource id"
}
