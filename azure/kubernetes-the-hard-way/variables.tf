variable "rg_name" {
  type = string
  description = "All resources will be deployed here."
}

variable "rg_location" {
  type = string
  description = "The Azure location of all resources."
}

variable "nsg_name" {
  type = string
  description = "Name of the NSG attached to the subnet."
}

variable "vnet_address_spaces" {
  type = list(string)
  description = "Address space of the VNET."
}

variable "subnet_prefixes" {
  type = list(string)
  description = "List of subnet address spaces."
}

variable "subnet_names" {
  type = list(string)
  description = "List of the subnet names to be created."
}

variable "vnet_name" {
  type = string
  description = "Name of the virtual network."
}

variable "lb_name" {
  type = string
  description = "Name of the Load Balancer."
}

variable "pip_lb_name" {
  type = string
  description = "Name of the PIP attached to the LB."
}

variable "pip_lb_alloc" {
  type = string
  description = "Allocation method for the PIP of the Load balancer."
}

variable "controllers_avail_set_name" {
  type = string
  description = "Name of the availability set dedicated to the controllers."
}

variable "workers_avail_set_name" {
  type = string
  description = "Name of the availability set dedicated to the workers."
}

variable "os_image" {
  type = map(string)
  description = "The details of the Azure VM image."
}

variable "vm_size" {
  type = string
  description = "Size of all VMs."
}

variable "controllers_count" {
  type = number
  description = "Number of controllers to be deployed."
}

variable "workers_count" {
  type = number
  description = "Number of workers to be deployed."
}

variable "tags" {
  type    = map(any)
  default = {}
  description = "Tags to be added to all resources."
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

locals {
  k8s_controller_prefix = "k8s_controller"
  k8s_worker_prefix     = "k8s_worker"
  pip_controller_prefix = "pip-${local.k8s_controller_prefix}"
  pip_worker_prefix     = "pip-${local.k8s_worker_prefix}"
}
