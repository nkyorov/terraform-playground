terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.94.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

# Will hold all resources
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
  tags     = var.tags
}

# For the subnet
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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

# Create VNET
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  vnet_name           = var.vnet_name
  address_spaces      = var.vnet_address_spaces
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names


  depends_on = [
    azurerm_resource_group.rg
  ]

  tags = var.tags
}

resource "azurerm_public_ip" "pip_lb" {
  name                = var.pip_lb_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = var.pip_lb_alloc

  tags = var.tags
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "lb_backend_addr_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "kubernetes-lb-pool"
}

resource "azurerm_availability_set" "as_kubernetes" {
  name                = var.avail_set_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "random_id" "randomId" {
  byte_length = 8
}

resource "azurerm_storage_account" "stg_k8s" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

##################################################
#                  K8s_Controllers               #
##################################################

resource "azurerm_public_ip" "pip_controllers" {
  count               = var.controllers_count
  name                = "${local.pip_controller_prefix}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

  tags = var.tags
}


# Create network interface
resource "azurerm_network_interface" "nic_controllers" {
  count               = var.controllers_count
  name                = "nic-${local.k8s_controller_prefix}-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.1${count.index + 1}"
    public_ip_address_id          = azurerm_public_ip.pip_controllers[count.index].id
  }
  enable_ip_forwarding = true

  tags = var.tags
}

# Add to LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "associate_nics_to_lb" {
  count                   = var.controllers_count
  network_interface_id    = azurerm_network_interface.nic_controllers[count.index].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_addr_pool.id
}

resource "azurerm_linux_virtual_machine" "k8s_controllers" {
  count = var.controllers_count

  name                = "${local.k8s_controller_prefix}_${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size

  network_interface_ids = [azurerm_network_interface.nic_controllers[count.index].id]

  os_disk {
    name                 = "OSDisk-${local.k8s_controller_prefix}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.stg_k8s.primary_blob_endpoint
  }

  availability_set_id = azurerm_availability_set.as_kubernetes.id

  admin_username                  = "kuberoot"
  computer_name                   = "k8s-controller-${count.index + 1}"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "kuberoot"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  tags = var.tags
}
