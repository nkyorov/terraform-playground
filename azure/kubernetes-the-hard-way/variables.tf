variable "rg_name" {}
variable "rg_location" {}
variable "nsg_name" {}

locals {
  nsg_security_rules = [{
    name                       = ""
    priority                   = ""
    direction                  = ""
    access                     = ""
    protocol                   = ""
    source_port_ranges         = ""
    destination_port_range     = ""
    source_port_range          = ""
    source_address_prefix      = ""
    destination_address_prefix = ""
    description                = ""
    }]
}