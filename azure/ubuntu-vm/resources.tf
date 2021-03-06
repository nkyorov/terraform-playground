# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
  name     = local.rg_name
  location = var.location

  tags = local.common_tags
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = local.vnet_name
  address_space       = [var.network_address_space[terraform.workspace]]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = local.common_tags

}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  count                = var.subnet_count[terraform.workspace]
  name                 = "${local.subnet_name}-00${count.index + 1}"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = [cidrsubnet(var.network_address_space[terraform.workspace], 8, count.index)]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  count               = var.instance_count[terraform.workspace]
  name                = "${local.public_ip}-00${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  allocation_method   = "Dynamic"

  tags = local.common_tags
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
  name                = local.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  count               = var.instance_count[terraform.workspace]
  name                = "${local.nic_name}-00${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  ip_configuration {
    name                          = "cfg-00${count.index + 1}"
    subnet_id                     = azurerm_subnet.myterraformsubnet[count.index % var.subnet_count[terraform.workspace]].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip[count.index].id
  }

  tags = merge(local.common_tags, { Subnet = azurerm_subnet.myterraformsubnet[count.index % var.subnet_count[terraform.workspace]].name })
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.instance_count[terraform.workspace]
  network_interface_id      = azurerm_network_interface.myterraformnic[count.index].id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.myterraformgroup.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.myterraformgroup.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

# Create an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
  count                 = var.instance_count[terraform.workspace]
  name                  = "${local.vm_name}-00${count.index + 1}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic[count.index].id]
  size                  = var.instance_size[terraform.workspace]

  os_disk {
    name                 = "DataDisk-${var.vm_name}-00${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "${var.vm_name}-00${count.index + 1}"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
  tags = merge(local.common_tags, { Subnet = azurerm_subnet.myterraformsubnet[count.index % var.subnet_count[terraform.workspace]].name })
}