variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VMSS instances"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key for authentication"
  type        = string
}


variable "subnet_id" {
  description = "The ID of the subnet where VMSS will be deployed"
  type        = string
}

variable "vnet_name" {
  type        = string
  description = "The name of the existing Virtual Network where Bastion and VMSS will be deployed"
}
