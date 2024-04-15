### Testing Variables ###
location                           = "westeurope"
resource_group_name                = "alz-subnet-module-test"
prereq_virtual_network_name        = "alz-subnet-module-test-vnet"
prereq_route_table_name            = "alz-subnet-module-test-rt"
prereq_network_security_group_name = "alz-subnet-module-test-nsg"
sub_resource_group_name            = "alz-subnet-module-test-network-sub-resources"

virtual_network_address_space                 = ["10.30.0.0/24"]
alz_existing_nsg_rt_address_space             = ["10.30.0.0/27"]
alz_new_nsg_rt_address_space                  = ["10.30.0.32/27"]
alz_new_nsg_rt_service_endpoint_address_space = ["10.30.0.64/27"]
alz_new_nsg_rt_delegate_address_space         = ["10.30.0.96/27"]
alz_new_nsg_rt_nva_ip_udr_address_space       = ["10.30.0.128/27"]
alz_new_nsg_existing_rt_address_space         = ["10.30.0.160/27"]
alz_existing_rg_address_space                 = ["10.30.0.192/27"]
alz_existing_rg_no_rt_address_space           = ["10.30.0.224/28"]
nva_ip_address                                = "10.20.0.4"

tags = {
  Configuration = "Terraform"
  Environment   = "Test"
  ModuleName    = "terraform-azurerm-alz-subnet"
}


