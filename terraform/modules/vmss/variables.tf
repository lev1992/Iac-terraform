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

variable "source_image_id" {
  description = "Optional Shared Image Gallery image version ID to use for the VMSS instances. When null, the default Ubuntu marketplace image is used."
  type        = string
  default     = null

  validation {
    condition     = var.source_image_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Compute/galleries/.+/images/.+/versions/.+$", var.source_image_id))
    error_message = "source_image_id must be a Shared Image Gallery image version resource ID."
  }
}

variable "source_image_reference" {
  description = "Marketplace image reference used only when source_image_id is null."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
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
