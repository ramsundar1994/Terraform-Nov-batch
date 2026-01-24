#Exmple toset + for_each loop

resource "azurerm_resource_group" "rg1" {
  name = "RG-01"
  location = "Westus"
}
resource "azurerm_network_security_group" "nsg-name" {
  name = "NSG-01"
  location = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}
resource "azurerm_network_security_rule" "nsg-rule" {
  for_each = toset(var.allowed_port)
  name =  "Rule-${each.value}"
  resource_group_name = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg-name.name
  direction = "Inbound"
  access = "Allow"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "10.0.0.0/24"
  destination_port_range = each.value
  protocol = "Tcp"
  priority = 100 +each.key
}

#Example 2 : LAB 4: MAP + keys() + for_each
resource "azurerm_virtual_network" "vnet-test" {
  name = "vNet-test"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  address_space = [ "10.0.0.0/16" ]
}
resource "azurerm_subnet" "subnet-test" {
  for_each = var.subnets
  name = each.key
  resource_group_name = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet-test.name
  address_prefixes = [each.value]
}