terraform {
  backend "azurerm" {
    resource_group_name  = "tf-state"
    storage_account_name = "terrastate20260412a"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}