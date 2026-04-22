# 1. Provider configuration for Azure
provider "azurerm" {
  features {}
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


variable "admin_username" {
  description = "The admin username for the virtual machines"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "The SSH public key for Linux authentication"
  type        = string
}

# 3. Resource Group 
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.azure_region
}

# 4. Networking - Virtual Network and Subnet
resource "azurerm_virtual_network" "main" {
  name                = "devops-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
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
  
  # References the subnet created in this file
  subnet_id           = azurerm_subnet.internal.id
}





