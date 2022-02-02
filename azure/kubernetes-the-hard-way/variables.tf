variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "nsg_name" {
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

variable "vnet_name" {
  type = string
}

variable "tags" {
  type    = map(any)
  default = {}
}

locals {
  nsg_security_rules = [{
    name                       = "Allow_SSH"
    priority                   = "1000"
    direction                  = "inbound"
    access                     = "allow"
    protocol                   = "tcp"
    source_port_ranges         = "*"
    destination_port_range     = "22"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allows external SSH."
    },
    {
      name                       = "Allow_HTTPS"
      priority                   = "1001"
      direction                  = "inbound"
      access                     = "allow"
      protocol                   = "tcp"
      source_port_ranges         = "*"
      destination_port_range     = "6443"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allows HTTPS."
  }]
}

