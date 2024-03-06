# Example: Using Pre-created Network Security Group and Route Table

This example demonstrates how to use the `haflidif/alz-subnet/azurerm` Terraform module to create a subnet in Azure and associate it with a pre-created Network Security Group (NSG) and Route Table.

## Pre-requisites Setup

First, we need to set up the necessary resources that our subnet will be associated with. This includes creating a resource group, a virtual network, a route table, and a network security group.

```hcl
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

resource "azurerm_route_table" "this" {
  name                = "rt-alz-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-alz-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}
```
## Creating Subnet and Associating with NSG and Route Table
Now, we can use the `haflidif/alz-subnet/azurerm` module to create a subnet and associate it with the pre-created NSG and Route Table. We pass in the necessary parameters, including the ID of the virtual network, route table, and network security group we created earlier.
```hcl
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
```
This will create a subnet named `snet-alz-01` within the `vnet-alz-01` virtual network and associate it with the `nsg-alz-01` NSG and `rt-alz-01` Route Table.