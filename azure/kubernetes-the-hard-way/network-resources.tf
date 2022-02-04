resource "azurerm_network_security_group" "network_security_group" {
  name                = var.nsg_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

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

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.resource_group.name
  vnet_name           = var.vnet_name
  address_spaces      = var.vnet_address_spaces
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  depends_on = [
    azurerm_resource_group.resource_group
  ]

  tags = var.tags
}

resource "azurerm_public_ip" "public_ip_lb" {
  name                = var.pip_lb_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = var.pip_lb_alloc

  tags = var.tags
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.public_ip_lb.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "lb_backend_addr_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "kubernetes-lb-pool"
}