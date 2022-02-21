variable "vm_resource_group_name" {
  type = string
}

variable "location" {
  type = string
  default = "westeurope"
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "vm_storage_account" {
  type = map(string)
}

variable "vm_public_ip_allocation_method" {
  type = string
}

variable "ip_configuration" {
  type = map(string)
}

variable "vm_public_ip_name" {
  type = string
}

variable "nic_name" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
  description = "(optional) describe your variable"
}

variable "log_analyics_rg_name" {
  type = string
  description = "(optional) describe your variable"
}

variable "vm_size" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "os_disk" {
  type = map(string)
}

variable "os_image" {
  type = map(string)
}

variable "vnet_rg" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_spaces" {
  type = list(string)
}

variable "subnet_prefixes" {
  type = list(string)
}

variable "subnet_names" {
  type = list(string)
}

variable "nsg_name" {
  type = string
}


locals {
  nsg_security_rules = [{
    name                       = "Allow_SSH"
    priority                   = "200"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_ranges         = "*"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "${chomp(data.http.myip.body)}/32"
    destination_address_prefix = "*"
    description                = "Allow SSH over port 22."
    },
    { name                       = "Allow_RDP"
      priority                   = "300"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "${chomp(data.http.myip.body)}/32"
      destination_address_prefix = "*"
      description                = "Allow RDP over 3389."
  }]
}