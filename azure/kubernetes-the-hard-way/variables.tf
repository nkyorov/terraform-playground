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

variable "lb_name" {
  type = string
}

variable "pip_lb_name" {
  type = string
}

variable "pip_lb_alloc" {
  type = string
}

variable "controllers_avail_set_name" {
  type = string
}

variable "workers_avail_set_name" {
  type = string
}

variable "os_image" {
  type = map(string)
}

variable "vm_size" {
  type = string
}

variable "controllers_count" {
  type = number
}

variable "workers_count" {
  type = number
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

locals {
  k8s_controller_prefix = "k8s_controller"
  k8s_worker_prefix     = "k8s_worker"
  pip_controller_prefix = "pip-${local.k8s_controller_prefix}"
  pip_worker_prefix     = "pip-${local.k8s_worker_prefix}"
}
