variable "vm_resource_group_name" {
  type = string
  description = "Name of the resource group dedicated to the VM and its related components."
}

variable "location" {
  type = string
  default = "westeurope"
  description = "Location of all resources."
}

variable "tags" {
  type    = map(any)
  default = {}
  description = "Tags applied to all resources."
}

variable "vm_storage_account" {
  type = map(string)
  description = "Storage account for boot diagnostics."
}

variable "vm_public_ip_allocation_method" {
  type = string
  description = "Allocation method for the VM's PIP."
}

variable "ip_configuration" {
  type = map(string)
  description = "NIC configuration."
}

variable "vm_public_ip_name" {
  type = string
  description = "Name of the VM's PIP."
}

variable "nic_name" {
  type = string
  description = "Name of the VM's NIC."
}

variable "log_analytics_workspace_name" {
  type = string
  description = "Resource name for the Log Analytics Workspace."
}

variable "log_analyics_rg_name" {
  type = string
  description = "Resource name for the RG holding the Log Analytics Workspace."
}

variable "vm_size" {
  type = string
  description = "Size of the VM."
}

variable "vm_name" {
  type = string
  description = "Name of the VM."
}

variable "os_disk" {
  type = map(string)
  description = "OS Disk details."
}

variable "os_image" {
  type = map(string)
  description = "VM OS image."
}

variable "vnet_rg" {
  type = string
  description = "RG holding the VNET."
}

variable "vnet_name" {
  type = string
  description = "Name of the VM."
}

variable "vnet_address_spaces" {
  type = list(string)
  description = "VNET address space."
}

variable "subnet_prefixes" {
  type = list(string)
  description = "List of subnet prefixes."
}

variable "subnet_names" {
  type = list(string)
  description = "Subnet names."
}

variable "nsg_name" {
  type = string
  description = "Name of the NSG."
}

variable "oms_proxy" {
  type = string
  description = "OMS Proxy configuration."
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
    { 
      name                       = "Allow_RDP"
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