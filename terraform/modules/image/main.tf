# 1. The gallery 
resource "azurerm_shared_image_gallery" "example" {
  name                = "my_compute_gallery"
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "My operating systems repository"
}

# 2. definition - "example" for Ubuntu
resource "azurerm_shared_image" "example" {
  name                = "ubuntu-template"
  gallery_name        = azurerm_shared_image_gallery.example.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"

  identifier {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
  }
} 

# 3. Image Version with Target Replication
resource "azurerm_shared_image_version" "example" {
  name                = "1.0.0"
  gallery_name        = azurerm_shared_image_gallery.example.name
  image_name          = azurerm_shared_image.example.name
  resource_group_name = var.resource_group_name
  location            = var.location 

  
  target_region {
    name                   = var.location 
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
}