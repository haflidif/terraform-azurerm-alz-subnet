##################################################
# VARIABLES                                      #
##################################################
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Region / Location where resources should be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group where virtual network is deployed + NSG and RT for testing the module with existing NSG and RT"
}

variable "prereq_virtual_network_name" {
  type        = string
  default     = "alz-subnet-module-test-vnet"
  description = "Virtual Network Name, virtual network needs to be created before subnet module can be tested"
}

variable "virtual_network_address_space" {
  type        = list(string)
  default     = ["10.30.0.0/24"]
  description = "List of all virtual network addresses"
}

variable "prereq_route_table_name" {
  type        = string
  default     = "alz-subnet-module-test-rt"
  description = "Route Table Name, for testing with existing NSG and RT"
}

variable "prereq_network_security_group_name" {
  type        = string
  default     = "alz-subnet-module-test-nsg"
  description = "Network Security Group Name, for testing with existing NSG and RT"
}

variable "sub_resource_group_name" {
  type        = string
  default     = "alz-subnet-module-test-sub-resources"
  description = "Sub Resource Group Name"
}

variable "alz_existing_nsg_rt_address_space" {
  type        = list(string)
  default     = ["10.30.0.0/27"]
  description = "Address prefix for the subnet test with existing NSG and RT"
}

variable "alz_new_nsg_rt_address_space" {
  type        = list(string)
  default     = ["10.30.0.32/27"]
  description = "Address prefix for the subnet test with new NSG and RT"
}

variable "alz_new_nsg_rt_delegate_address_space" {
  type        = list(string)
  default     = ["10.30.0.64/27"]
  description = "Address prefix for the subnet test with new NSG and RT and subnet delegation"
}

variable "alz_new_nsg_rt_service_endpoint_address_space" {
  type        = list(string)
  default     = ["10.30.0.96/27"]
  description = "Address prefix for the subnet test with new NSG and RT and subnet service endpoint"
}

variable "alz_new_nsg_rt_nva_ip_udr_address_space" {
  type        = list(string)
  default     = ["10.30.0.128/27"]
  description = "Address prefix for the subnet test with new NSG and RT and udr for Network Virtual Appliance"
}

variable "alz_new_nsg_existing_rt_address_space" {
  type        = list(string)
  default     = ["10.30.0.160/27"]
  description = "Address prefix for the subnet test with new NSG and existing RT"
}

variable "nva_ip_address" {
  description = "(Optional) The IP address of the network virtual appliance often a firewall, located in a hub virtual network, this is used to create user defined route to route"
  type        = string
  default     = "10.20.0.4"
}

variable "tags" {
  type        = map(string)
  description = "(Optional): Resource Tags"
  default     = {}
}