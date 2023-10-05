###########################################################
#          Pre Requisites for the module testing          #
###########################################################

# Creating Random id to append to the resource group name
resource "random_id" "rg" {
  byte_length = 4
}

# Creating multiple Random id to append to the resources created by the module.
resource "random_id" "test" {
  count       = 5
  byte_length = 4
}

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}-${lower(random_id.rg.hex)}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prereq_virtual_network_name}-${lower(random_id.rg.hex)}"
  address_space       = var.virtual_network_address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# Pre-creating route table to test the module with existing route table
resource "azurerm_route_table" "this" {
  name                = "${var.prereq_route_table_name}-${lower(random_id.rg.hex)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

# Pre-creating network security group to test the module with existing network security group
resource "azurerm_network_security_group" "this" {
  name                = "${var.prereq_network_security_group_name}-${lower(random_id.rg.hex)}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

#############################################################
#          Testing: Subnet with existing NSG and RT         #
#############################################################

module "subnet_existing_nsg_rt" {
  source                        = "../.."
  subnet_name                   = "alz-subnet-module-test-snet-existing-nsg-rt"
  address_prefixes              = var.alz_existing_nsg_rt_address_space
  virtual_network_resource_id   = azurerm_virtual_network.this.id
  location                      = azurerm_resource_group.this.location
  create_network_security_group = false
  create_route_table            = false
  route_table_id                = azurerm_route_table.this.id
  network_security_group_id     = azurerm_network_security_group.this.id
}

############################################################
#          Testing: Subnet by creating NSG and RT          #
############################################################

module "subnet_new_nsg_rt" {
  source                      = "../.."
  subnet_name                 = "alz-subnet-module-test-snet-new-nsg-rt"
  address_prefixes            = var.alz_new_nsg_rt_address_space
  virtual_network_resource_id = azurerm_virtual_network.this.id
  location                    = azurerm_resource_group.this.location
  sub_resource_group_name     = "${var.sub_resource_group_name}-${lower(random_id.test[0].hex)}"
  route_table_name            = "${var.prereq_route_table_name}-${lower(random_id.test[0].hex)}"
  network_security_group_name = "${var.prereq_network_security_group_name}-${lower(random_id.test[0].hex)}"
  tags                        = var.tags

  depends_on = [module.subnet_existing_nsg_rt]
}

##########################################################
#          Testing: Subnet with Service Endpoint         #
##########################################################

module "subnet_service_endpoint" {
  source                      = "../.."
  subnet_name                 = "alz-subnet-module-test-snet-service-endpoint"
  address_prefixes            = var.alz_new_nsg_rt_service_endpoint_address_space
  virtual_network_resource_id = azurerm_virtual_network.this.id
  location                    = azurerm_resource_group.this.location
  sub_resource_group_name     = "${var.sub_resource_group_name}-${lower(random_id.test[1].hex)}"
  route_table_name            = "${var.prereq_route_table_name}-${lower(random_id.test[1].hex)}"
  network_security_group_name = "${var.prereq_network_security_group_name}-${lower(random_id.test[1].hex)}"
  service_endpoint_names      = ["Microsoft.Storage", "Microsoft.Sql"]
  tags                        = var.tags

  depends_on = [module.subnet_new_nsg_rt]
}

#############################################################
#          Testing: Subnet with Service Delegation          #
#############################################################

module "subnet_service_delegation" {
  source                      = "../.."
  subnet_name                 = "alz-subnet-module-test-snet-service-delegation"
  address_prefixes            = var.alz_new_nsg_rt_delegate_address_space
  virtual_network_resource_id = azurerm_virtual_network.this.id
  location                    = azurerm_resource_group.this.location
  sub_resource_group_name     = "${var.sub_resource_group_name}-${lower(random_id.test[2].hex)}"
  route_table_name            = "${var.prereq_route_table_name}-${lower(random_id.test[2].hex)}"
  network_security_group_name = "${var.prereq_network_security_group_name}-${lower(random_id.test[2].hex)}"
  delegation_service_name     = "Microsoft.ContainerInstance/containerGroups"
  tags                        = var.tags

  depends_on = [module.subnet_service_endpoint]
}

##################################################################
#          Testing: Subnet with NSG, RT and UDR for NVA          #
################################################################## 

module "subnet_nsg_rt_udr" {
  source                      = "../.."
  subnet_name                 = "alz-subnet-module-test-snet-nsg-rt-udr"
  address_prefixes            = var.alz_new_nsg_rt_nva_ip_udr_address_space
  virtual_network_resource_id = azurerm_virtual_network.this.id
  location                    = azurerm_resource_group.this.location
  sub_resource_group_name     = "${var.sub_resource_group_name}-${lower(random_id.test[3].hex)}"
  route_table_name            = "${var.prereq_route_table_name}-${lower(random_id.test[3].hex)}"
  network_security_group_name = "${var.prereq_network_security_group_name}-${lower(random_id.test[3].hex)}"
  nva_ip_address              = var.nva_ip_address
  tags                        = var.tags

  depends_on = [module.subnet_service_delegation]
}

#############################################################
#          Testing: Subnet with new NSG & Existing RT       #
#############################################################

module "subnet_new_nsg_existing_rt" {
  source                        = "../.."
  subnet_name                   = "alz-subnet-module-test-snet-new-nsg-existing-rt"
  address_prefixes              = var.alz_new_nsg_existing_rt_address_space
  virtual_network_resource_id   = azurerm_virtual_network.this.id
  location                      = azurerm_resource_group.this.location
  sub_resource_group_name       = "${var.sub_resource_group_name}-${lower(random_id.test[4].hex)}"
  create_network_security_group = true
  create_route_table            = false
  route_table_id                = azurerm_route_table.this.id
  network_security_group_name   = "${var.prereq_network_security_group_name}-${lower(random_id.test[4].hex)}"
  tags                          = var.tags

  depends_on = [module.subnet_nsg_rt_udr]
}

output "subnets" {
  value = {
    subnet_existing_nsg_rt     = module.subnet_existing_nsg_rt.subnet_id
    subnet_new_nsg_rt          = module.subnet_new_nsg_rt.subnet_id
    subnet_service_endpoint    = module.subnet_service_endpoint.subnet_id
    subnet_service_delegation  = module.subnet_service_delegation.subnet_id
    subnet_nsg_rt_udr          = module.subnet_nsg_rt_udr.subnet_id
    subnet_new_nsg_existing_rt = module.subnet_new_nsg_existing_rt.subnet_id
  }
}

output "route_table_ids" {
  value = {
    subnet_existing_nsg_rt     = module.subnet_existing_nsg_rt.subnet_route_table_id
    subnet_new_nsg_rt          = module.subnet_new_nsg_rt.subnet_route_table_id
    subnet_service_endpoint    = module.subnet_service_endpoint.subnet_route_table_id
    subnet_service_delegation  = module.subnet_service_delegation.subnet_route_table_id
    subnet_nsg_rt_udr          = module.subnet_nsg_rt_udr.subnet_route_table_id
    subnet_new_nsg_existing_rt = module.subnet_new_nsg_existing_rt.subnet_route_table_id
  }
}

output "network_security_group_ids" {
  value = {
    subnet_existing_nsg_rt     = module.subnet_existing_nsg_rt.subnet_nsg_id
    subnet_new_nsg_rt          = module.subnet_new_nsg_rt.subnet_nsg_id
    subnet_service_endpoint    = module.subnet_service_endpoint.subnet_nsg_id
    subnet_service_delegation  = module.subnet_service_delegation.subnet_nsg_id
    subnet_nsg_rt_udr          = module.subnet_nsg_rt_udr.subnet_nsg_id
    subnet_new_nsg_existing_rt = module.subnet_new_nsg_existing_rt.subnet_nsg_id
  }
}
