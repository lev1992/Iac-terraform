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
  description = "The name of the virtual network where VMSS will be deployed"
  type        = string
}

variable "my_home_ip" {
  type        = string
  description = "Allowed home public IP CIDR for SSH access"
}

variable "tags" {
  description = "Tags to apply to Azure resources"
  type        = map(string)
  default     = {}
}
