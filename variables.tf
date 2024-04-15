######################################
###       Required Variables       ###
######################################
variable "subnet_name" {
  description = "(Required) Name of the subnet. Changing this forces a new resource to be created."
  type        = string
}

variable "address_prefixes" {
  description = "(Required) The Address prefix to use for the subnet."
  type        = list(string)
}

variable "virtual_network_resource_id" {
  description = "(Required) The ID of the virtual network where the subnet should be created. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the Azure location where the resources should be created. Changing this forces a new resource to be created."
  type        = string
}

######################################
###       Optional Variables       ###
######################################

variable "use_existing_resource_group" {
  description = "(Optional) Boolean flag which controls if an existing resource group should be used. Defaults to `false`."
  type        = bool
  default     = false
}

variable "existing_resource_group_name" {
  description = "(Optional) The name of an existing resource group where the nsg and route table will be created. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "sub_resource_group_name" {
  description = "(Optional) The name of the resource group where the sub-resources will be created. Changing this forces a new resource to be created."
  type        = string
  default     = ""
}

variable "create_network_security_group" {
  description = "(Optional) Boolean flag which controls if network security group should be created. Defaults to `true`. Set to `false` and provide value for `network_security_group_id` to reference existing network security group."
  type        = bool
  default     = true
}

variable "network_security_group_id" {
  description = "(Optional) The ID of existing network security group to associate with the subnet."
  type        = string
  default     = ""
  nullable    = true
}

variable "network_security_group_name" {
  description = "(Optional) The name of the new network security group to associate with the subnet."
  type        = string
  default     = ""
}

variable "create_route_table" {
  description = "(Optional) Boolean flag which controls if route table should be created. Defaults to `true`. Set to `false` and either provide value for `route_table_id` to reference existing route table, or skip providing value for `route_table_id` to not use a route table at all."
  type        = bool
  default     = true
}

variable "route_table_id" {
  description = "(Optional) The ID of existing route table to associate with the subnet."
  type        = string
  default     = ""
  nullable    = true
}

variable "route_table_name" {
  description = "(Optional) The name of the new route table to associate with the subnet."
  type        = string
  default     = ""
}

variable "nva_ip_address" {
  description = "(Optional) The IP address of the network virtual appliance often a firewall, located in a hub virtual network, this is used to create user defined route to route 0.0.0.0/0 traffic to the network virtual appliance."
  type        = string
  default     = ""
}

variable "private_endpoint_network_policies_enabled" {
  description = "(Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. Defaults to `true`"
  type        = bool
  default     = true
}

variable "private_link_service_network_policies_enabled" {
  description = "(Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. Defaults to `true`"
  type        = bool
  default     = true
}

variable "delegation_service_name" {
  description = "(Optional) Provide the service name for the subnet delegation configuration."
  type        = string
  default     = ""
}

variable "service_endpoint_names" {
  description = "(Optional) List of service endpoints to associate with the subnet."
  type        = list(string)
  default     = []
}

variable "disable_bgp_route_propagation" {
  description = "(Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. `true` means disable. Defaults to `false`, when used in combination with `create_sub_network_resources` and 'nva_ip_address' this should be set to `true` to prevent the default 0.0.0.0/0 route to be propagated in the route table via BGP."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
