# Simple usage to showcase several functionalities of the module

########################
# Pre-requisites Setup #
########################

resource "azurerm_resource_group" "this" {
  name     = "rg-test-01"
  location = "westeurope"
}

resource "azurerm_resource_group" "existing" {
  name     = "rg-test-existing-01"
  location = "westeurope"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-alz-01"
  address_space       = ["10.30.0.0/24"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

###################################################################################################################
#    Example Usage: Creating Subnet in addition to NSG and RT within a existing resource group                    #
###################################################################################################################

module "subnet" {
  source                        = "haflidif/alz-subnet/azurerm"
  subnet_name                   = "snet-alz-01"
  address_prefixes              = ["10.30.0.0/27"]
  virtual_network_resource_id   = azurerm_virtual_network.this.id
  location                      = azurerm_resource_group.this.location
  create_network_security_group = true
  create_route_table            = true
  use_existing_resource_group   = true
  existing_resource_group_name  = azurerm_resource_group.existing.name
  route_table_name              = "rt-alz-01"
  network_security_group_name   = "nsg-alz-01"
}