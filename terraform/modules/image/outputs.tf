output "gallery_id" {
  description = "ID of the Azure Compute Gallery"
  value       = azurerm_shared_image_gallery.example.id
}

output "image_definition_id" {
  description = "ID of the shared image definition"
  value       = azurerm_shared_image.example.id
}

output "image_version_id" {
  description = "ID of the shared image version. Null when source_managed_image_id is not set."
  value       = try(azurerm_shared_image_version.example[0].id, null)
}
