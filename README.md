# terraform-azurerm-alz-subnet

# Description
This module is used to deploy subnet with network security group (NSG) and route table (RT) associated as workaround to the `azurerm_subnet` resource so it doesn't conflict with the Azure Landing Zone policies [`Subnets should have a Network Security Group`](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Subnet-Without-Nsg.html) and [`Subnets should have a User Defined Route`](https://www.azadvertizer.net/azpolicyadvertizer/Deny-Subnet-Without-Udr.html) which are commonly used within large/medium sized enterprises in the [Azure Landing Zone Reference Architecture](https://learn.microsoft.com/azure/architecture/landing-zones/terraform/landing-zone-terraform?wt.mc_id=SEC-MVP-5005265).

# Why
Why not just use the terraform resource `azurerm_subnet` to deploy the subnet within the virtual network deployed by the e.g [Azure Landing Zone vending module](https://registry.terraform.io/modules/Azure/lz-vending/azurerm/latest) ?

That is because it's known for having a bug that conflicts with these `deny` policies due to how the resouce is designed, and how it's not able to associate the `Network Security Group (NSG)` and the `Route Table (RT)` to the subnet when the resouce is deployed, due to those restrictions in the resource it needs to use seperate resources for that action `azurerm_subnet_network_security_group_association` and the `azurerm_route_table_association` but unfortunately that conflicts with the `Deny` policies and doesn't allow you to create the subnet.

The only way to deploy a subnet that doesn't conflict with these policies is to use the `azurerm_virtual_network` resource to deploy the subnet and reference the network security group, and the route table in one API call. 

However, that only resolves the part of the problem as the `azurerm_virtual_network` resouce doesn't support complex configurations on the subnet like `Subnet Delegation`, `Service Endpoints` and `Private link-/ endpoint network policies` 

In addition to prevent autonomous work teams/owners/contributors of their Landing Zone to create a subnet within their own code repository, and constant need to involve the Platform Team to create the subnets for the landing zones.

### Issues that have been previously been posted and resolved with workarounds on this bug when creating subnet while adhearing to these policies.
These github issues have been around since mid 2019, some of them have been resolved with workarounds, workaround similar to what is being used in this module, and some are still open.

- [:arrow_forward: Feature Request: Subnets defined in-line within the Virtual Network resource doesn't support all parameters #3917 ](https://github.com/hashicorp/terraform-provider-azurerm/issues/3917)
- [:arrow_forward: Example of using the Subnet Association resources with Azure Policy #9022](https://github.com/hashicorp/terraform-provider-azurerm/issues/9022)
- [:arrow_forward: Unable to create subnet due to Azure policy deny subnet with NSG, need NSG parameter #16952](https://github.com/hashicorp/terraform-provider-azurerm/issues/16952)
- [:arrow_forward: Support for azurerm_subnet to configure route table association, nsg association #16921](https://github.com/hashicorp/terraform-provider-azurerm/issues/16921)

### Known Issues in this module.
Please have a look at the [Known Issues](#known-issues) section for more information, before posting an issue on this repository.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.9, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.11, < 4.0 |

## Simple module usage

```hcl
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
```
### See more usage examples here:
- [:arrow_forward: Example Usage: Creating Subnet, NSG and RT](examples/example-2/main.tf)
- [:arrow_forward: Example Usage: Creating Subnet, NSG, RT, Adding UDR for NVA and Disabling BGP Propagation on route table](examples/example-3/main.tf)
- [:arrow_forward: Example Usage: Creating Subnet, NSG, RT and adding service endpoints to the subnet for Azure Storage and SQL](examples/example-4/main.tf)

> :information_source: **Note:** <br>
> Otherwise, see the full module test here: [:arrow_forward: test/autotest](test/autotest/main.tf) <br>

## Resources

| Name | Type |
|------|------|
| [azapi_resource.subnet](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.sub_resouces_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route.default_route_to_nva](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefixes"></a> [address\_prefixes](#input\_address\_prefixes) | (Required) The Address prefix to use for the subnet. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the Azure location where the resources should be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | (Required) Name of the subnet. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_virtual_network_resource_id"></a> [virtual\_network\_resource\_id](#input\_virtual\_network\_resource\_id) | (Required) The ID of the virtual network where the subnet should be created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_create_network_security_group"></a> [create\_network\_security\_group](#input\_create\_network\_security\_group) | (Optional) Boolean flag which controls if network security group should be created. Defaults to `true`. Set to `false` and provide value for `network_security_group_id` to reference existing network security group. | `bool` | `true` | no |
| <a name="input_create_route_table"></a> [create\_route\_table](#input\_create\_route\_table) | (Optional) Boolean flag which controls if route table should be created. Defaults to `true`. Set to `false` and provide value for `route_table_id` to reference existing route table. | `bool` | `true` | no |
| <a name="input_delegation_service_name"></a> [delegation\_service\_name](#input\_delegation\_service\_name) | (Optional) Provide the service name for the subnet delegation configuration. | `string` | `""` | no |
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | (Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. `true` means disable. Defaults to `false`, when used in combination with `create_sub_network_resources` and 'nva\_ip\_address' this should be set to `true` to prevent the default 0.0.0.0/0 route to be propagated in the route table via BGP. | `bool` | `false` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | (Optional) The name of an existing resource group where the nsg and route table will be created. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_network_security_group_id"></a> [network\_security\_group\_id](#input\_network\_security\_group\_id) | (Optional) The ID of existing network security group to associate with the subnet. | `string` | `""` | no |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | (Optional) The name of the new network security group to associate with the subnet. | `string` | `""` | no |
| <a name="input_nva_ip_address"></a> [nva\_ip\_address](#input\_nva\_ip\_address) | (Optional) The IP address of the network virtual appliance often a firewall, located in a hub virtual network, this is used to create user defined route to route 0.0.0.0/0 traffic to the network virtual appliance. | `string` | `""` | no |
| <a name="input_private_endpoint_network_policies_enabled"></a> [private\_endpoint\_network\_policies\_enabled](#input\_private\_endpoint\_network\_policies\_enabled) | (Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. Defaults to `true` | `bool` | `true` | no |
| <a name="input_private_link_service_network_policies_enabled"></a> [private\_link\_service\_network\_policies\_enabled](#input\_private\_link\_service\_network\_policies\_enabled) | (Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. Defaults to `true` | `bool` | `true` | no |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | (Optional) The ID of existing route table to associate with the subnet. | `string` | `""` | no |
| <a name="input_route_table_name"></a> [route\_table\_name](#input\_route\_table\_name) | (Optional) The name of the new route table to associate with the subnet. | `string` | `""` | no |
| <a name="input_service_endpoint_names"></a> [service\_endpoint\_names](#input\_service\_endpoint\_names) | (Optional) List of service endpoints to associate with the subnet. | `list(string)` | `[]` | no |
| <a name="input_sub_resource_group_name"></a> [sub\_resource\_group\_name](#input\_sub\_resource\_group\_name) | (Optional) The name of the resource group where the sub-resources will be created. Changing this forces a new resource to be created. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_use_existing_resource_group"></a> [use\_existing\_resource\_group](#input\_use\_existing\_resource\_group) | (Optional) Boolean flag which controls if an existing resource group should be used. Defaults to `false`. | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Virtual Network Subnet resource id |
| <a name="output_subnet_nsg_id"></a> [subnet\_nsg\_id](#output\_subnet\_nsg\_id) | Network Security Group resource id |
| <a name="output_subnet_route_table_id"></a> [subnet\_route\_table\_id](#output\_subnet\_route\_table\_id) | Route Table resource id |
## Modules

No modules.

<!-- END_TF_DOCS -->

## Argument Reference
The following arguments are supported:

- `subnet_name` - (Required) Name of the subnet. Changing this forces a new resource to be created.

- `address_prefixes` - (Required) The Address prefix to use for the subnet.
  > :information_source: **NOTE:**
  > <br>
  > Currently only a single address prefix can be set as the [Multiple Subnet Address Prefixes](https://github.com/Azure/azure-cli/issues/18194#issuecomment-880484269) Feature is not yet in public preview or general availability. <br>

- `virtual_network_resource_id` - (Required) The ID of the virtual network where the subnet should be created. Changing this forces a new resource to be created.

- `location` - (Required) Specifies the Azure location where the resources should be created. Changing this forces a new resource to be created.

- `use_existing_resource_group` - (Optional) Boolean flag which controls if an existing resource group should be used for the NSG and Route Table. Defaults to `false`.

- `existing_resource_group_name` - (Optional) The name of an existing resource group where the NSG and Route Table will be created. Changing this forces a new resource to be created.

- `create_network_security_group` - (Optional) Boolean flag which controls if network security group should be created. Defaults to `true`. Set to `false` and provide value for **`network_security_group_id`** to reference existing network security group.
  > :information_source: **NOTE:**
  > <br>
  > If this is set to **`false`** the following argument is required **`network_security_group_id`** if it is not **`set`** then the deployment will conflict with the Azure Policies and subnet can't be deployed in compliance with the policy. <br>

- `network_security_group_id` - (Optional) The ID of existing network security group to associate with the subnet, make sure the **`create_sub_network_resources`** is set to **`false`** if you want to reference an existing network security group.

- `network_security_group_name` - (Optional) The name of the new network security group to associate with the subnet.

- `create_route_table` - (Optional) Boolean flag which controls if route table should be created. Defaults to `true`. Set to `false` and provide value for **`route_table_id`** to reference existing route table.
  > :information_source: **NOTE:**
  > <br>
  > If this is set to **`false`** the following argument is required **`route_table_id`** if it is not **`set`** then the deployment will conflict with the Azure Policies and subnet can't be deployed in compliance with the policy. <br>

- `route_table_id` - (Optional) The ID of existing route table to associate with the subnet.

- `route_table_name` - (Optional) The name of the new route table to associate with the subnet.

- `nva_ip_address` - (Optional) The IP address of the network virtual appliance often a firewall, located in a hub virtual network, this is used to create user defined route to route
  > :information_source: **NOTE:**
  > <br>
  > Specify the IP address of the network virtual appliance often a firewall, located in a hub virtual network, this is used to create user defined route in the new route table to route `0.0.0.0/0` to the network virtual appliance. <br>

- `sub_resource_group_name` - (Optional) The name of the resource group where the sub-resources will be created. Changing this forces a new resource to be created.

- `delegation_service_name` - (Optional) Provide the service name for the subnet delegation configuration.
  > :information_source: **NOTE:** <br>
  > Delegating to service may not be available in all regions. Check if the service you are delegating to is available in your region using the [Azure CLI](https://learn.microsoft.com/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-list-available-delegations()&wt.mc_id=SEC-MVP-5005265). <br>

- `service_endpoint_names` - (Optional) List of service endpoints to associate with the subnet, multiple service endpoints are supported.
  > :information_source: **NOTE:**
  > <br>
  > In short Service Endpoints are used to secure Azure service resources to use the virtual network instead of the public internet, utilizing the azure backbone network. Multiple Service Endpoints can be defined on each subnet. <br>

  **Generally available service endpoints for all regions are:** <br>
  `Microsoft.Storage`, `Microsoft.Storage.Global`, `Microsoft.Sql`, `Microsoft.AzureCosmosDB`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.EventHub`, `Microsoft.AzureActiveDirectory`, `Microsoft.Web`, `Microsoft.CognitiveServices` <br>
  
  
  **Public Preview:** <br>
  `Microsoft.ContainerRegistry`

  For the most up-to-date notification and list of available service endpoints in your region check the [Azure virtual network service endpoints documentation](https://learn.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview?wt.mc_id=SEC-MVP-5005265). <br>
  

- `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. Defaults to `true`
  > :information_source: **NOTE:**
  > <br>
  > Private Link Service Network Policies are enabled by default to ensure that traffic from Private Link services go through the Network Security Group and uses the User Defined Routes in the route table associated with the subnet. <br>
  > If this is set to **`false`** the traffic for all private link services will bypass the Network Security Group and the User Defined Routes in the route table associated with the subnet. <br>

- `private_endpoint_network_policies_enabled` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to `true` will Enable the policy and setting this to `false` will Disable the policy. Defaults to `true`
  > :information_source: **NOTE:**
  > <br>
  > Private Endpoint Network Policies are enabled by default to ensure that traffic from the private endpoint go through the Network Security Group and uses the User Defined Routes in the route table associated with the subnet. <br>
  > If this is set to **`false`** the traffic for all private endpoints in the subnet will bypass the Network Security Group and the User Defined Routes in the route table associated with the subnet. <br>

- `disable_bgp_route_propagation` - (Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. `true` means disable. Defaults to `false`, when used in combination with `create_sub_network_resources` and `nva_ip_address` this should be set to `true` to override the default route `0.0.0.0/0` and to prevent routes learned by BGP (Route Propagation) to bypass the network virtual appliance.

- `tags` - (Optional) A mapping of tags to assign to the resource.

## Authors
Originally created by [Haflidi Fridthjofsson](https://github.com/haflidif)

## Other Resources
- [Microsoft.Network virtualNetworks/subnets - Bicep, ARM template & Terraform AzAPI reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets?pivots=deployment-language-terraform&wt.mc_id=SEC-MVP-5005265)
- [Azure Virtual Network Service Endpoints](https://learn.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview?wt.mc_id=SEC-MVP-5005265)
- [Azure Virtual Network Subnet Delegation](https://docs.microsoft.com/azure/virtual-network/subnet-delegation-overview?wt.mc_id=SEC-MVP-5005265)

## Known Issues

### Response 409: 409 Conflict, Error Code: AnotherOperationInProgress
The Azure API might throw an `Response 409: 409 Conflict`, `Error Code: AnotherOperationInProgress` when creating the subnet, this is due to dely in the Azure API when the `virtual network` resource is being updated and another `create/update/delete` is ran at the same time, in parallel or before the Azure API catches up with the previous operation. <br>

```powershell
| --------------------------------------------------------------------------------
│ RESPONSE 409: 409 Conflict
│ ERROR CODE: AnotherOperationInProgress
│ --------------------------------------------------------------------------------
│ {
│   "error": {
│     "code": "AnotherOperationInProgress",
│     "message": "Another operation on this or dependent resource is in progress. To retrieve status of the operation use uri: https://management.azure.com/subscriptions/<GUID_REMOVED>/providers/Microsoft.Network/locations/westeurope/operations/<GUID_REMOVED>?api-version=2023-04-01.",
│     "details": []
│   }
│ }
│ --------------------------------------------------------------------------------
```

  This happens particularly when calling the module multiple times in the same terraform run, the workaround is to use explicit `depends_on` on the module resource to ensure that the module is ran sequentially e.g. <br>

  ```hcl
  module "subnet1" {
    source = "haflidif/alz-subnet/azurerm"
    ...ommitted for brevity
  }

  module "subnet2" {
    source = "haflidif/alz-subnet/azurerm"
    ...ommitted for brevity
    depends_on = [ module.subnet1 ]
  }
  ```
  **See the following testing mechanism being used to test the module with multiple subnets in the same terraform run:** <br>
  [:arrow_forward: test/autotest](test/autotest/main.tf)
  
  **Please submit a issue on this repository if you find a better workaround or solution to this issue.**
  <br>

  > :information_source: **NOTE:**
  > <br>
  > It's a known issue not specifically related to this module, but to the `azurerm` provider and the `Azure API` and is being tracked in the following github issue: [:arrow_forward: Subnets on same vnet fail due to parrallel setup #3780](https://github.com/hashicorp/terraform-provider-azurerm/issues/3780)
