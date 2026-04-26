# 1. Provider configuration for Azure
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# 2. Variables definition
variable "azure_region" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "southeastasia"
}

variable "rg_name" {
  description = "The name of the resource group"
  type        = string
  default     = "devops-project-rg"
}

variable "environment" {
  description = "Deployment environment tag value"
  type        = string
  default     = "Dev"
}

variable "my_home_ip" {
  description = "Allowed home public IP CIDR for SSH access"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machines"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "The SSH public key for Linux authentication"
  type        = string

  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-[^ ]+) [A-Za-z0-9+/=]+( .*)?$", trimspace(var.ssh_public_key)))
    error_message = "The public key must be a valid OpenSSH format."
  }
}

variable "alert_email_receivers" {
  description = "Email receivers for Azure Monitor alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

locals {
  common_tags = {
    Environment = terraform.workspace
  }
}

# 3. Resource Group 
resource "azurerm_resource_group" "main" {
  name     = "${terraform.workspace}-${var.rg_name}"
  location = var.azure_region
  tags     = local.common_tags
}

# 4. Networking - Virtual Network and Subnet
resource "azurerm_virtual_network" "main" {
  name                = "${terraform.workspace}-devops-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "internal" {
  name                 = "internal-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}


# This connects to modules/vmss/ folder
module "my_vmss" {
  source              = "./modules/vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  admin_username      = var.admin_username
  ssh_public_key      = var.ssh_public_key
  vnet_name           = azurerm_virtual_network.main.name
  my_home_ip          = var.my_home_ip
  tags                = local.common_tags

  # References the subnet created in this file
  subnet_id = azurerm_subnet.internal.id
}

resource "azurerm_subnet_network_security_group_association" "internal" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = module.my_vmss.network_security_group_id
}

module "monitor_alerts" {
  source               = "./modules/monitor_alerts"
  resource_group_name  = azurerm_resource_group.main.name
  target_resource_id   = module.my_vmss.vmss_id
  target_resource_name = "internal-vmss"
  email_receivers      = var.alert_email_receivers
  tags                 = local.common_tags

  depends_on = [module.my_vmss]
}


module "vmss" {
  source = "./modules/vmss"

  source_image_id = module.image.image_version_i

  }