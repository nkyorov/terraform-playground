resource "azurerm_resource_group" "vnet_resource_group" {
  name     = var.vnet_rg
  location = var.location

  tags = var.tags
}

module "network" {
  source              = "Azure/network/azurerm"
  vnet_name           = var.vnet_name
  resource_group_name = azurerm_resource_group.vnet_resource_group.name
  address_spaces      = var.vnet_address_spaces
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  tags                = var.tags
  depends_on = [
    azurerm_resource_group.vnet_resource_group
  ]
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.vnet_resource_group.name

  dynamic "security_rule" {
    for_each = local.nsg_security_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }

  }
  tags = var.tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "link_nsg" {
  subnet_id                 = module.network.vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.network_security_group.id
}