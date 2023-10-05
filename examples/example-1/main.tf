# Simple usage to showcase the functionality of the module

########################
# Pre-requisites Setup #
########################

resource "azurerm_resource_group" "this" {
  name     = "rg-test-01"
  location = "westeurope"
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-alz-01"
  address_space       = ["10.30.0.0/24"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# Pre-creating route table to showcase simple usage of the module
resource "azurerm_route_table" "this" {
  name                = "rt-alz-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# Pre-creating network security group to showcase simple usage of the module
resource "azurerm_network_security_group" "this" {
  name                = "nsg-alz-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

########################
#    Example Usage     #
########################

module "subnet" {
  source                        = "haflidif/alz-subnet/azurerm"
  subnet_name                   = "snet-alz-01"
  address_prefixes              = ["10.30.0.0/27"]
  virtual_network_resource_id   = azurerm_virtual_network.this.id
  location                      = azurerm_resource_group.this.location
  create_network_security_group = false
  create_route_table            = false
  route_table_id                = azurerm_route_table.this.id
  network_security_group_id     = azurerm_network_security_group.this.id
}