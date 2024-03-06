# Example: Creating Subnet, NSG, Route Table, and Adding UDR for NVA

This example demonstrates how to use the `haflidif/alz-subnet/azurerm` Terraform module to create a subnet in Azure, associate it with a Network Security Group (NSG) and Route Table, add a User Defined Route (UDR) for a Network Virtual Appliance (NVA), and disable BGP route propagation on the route table.

## Pre-requisites Setup

First, we need to set up the necessary resources that our subnet will be associated with. This includes creating a resource group and a virtual network.

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
```
## Creating Subnet, NSG, Route Table, Adding UDR for NVA, and Disabling BGP Propagation
Now, we can use the `haflidif/alz-subnet/azurerm` module to create a subnet, NSG, and Route Table, add a UDR for an NVA, and disable BGP route propagation. We pass in the necessary parameters, including the ID of the virtual network we created earlier, the IP address of the NVA, and flags to indicate that we want to create an NSG and Route Table and disable BGP route propagation.
```hcl
module "subnet" {
  source                        = "haflidif/alz-subnet/azurerm"
  subnet_name                   = "snet-alz-01"
  address_prefixes              = ["10.30.0.0/27"]
  virtual_network_resource_id   = azurerm_virtual_network.this.id
  location                      = azurerm_resource_group.this.location
  create_network_security_group = true
  create_route_table            = true
  sub_resource_group_name       = "rg-snet-alz-01-sub-resources"
  route_table_name              = "rt-alz-01"
  network_security_group_name   = "nsg-alz-01"
  disable_bgp_route_propagation = true
  nva_ip_address                = "10.20.0.4"
}
```
This will create a subnet named `snet-alz-01` within the `vnet-alz-01` virtual network. It will also create an NSG named `nsg-alz-01` and a Route Table named `rt-alz-01` within the `rg-snet-alz-01-sub-resources` resource group. The route table will have a UDR added for an NVA with the IP address `10.20.0.4`, and BGP route propagation will be disabled.