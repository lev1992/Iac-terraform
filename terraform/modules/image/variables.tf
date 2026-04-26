# modules/image/variables.tf

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "gallery_name" {
  description = "Name of the Azure Compute Gallery"
  type        = string
  default     = "my_compute_gallery"
}

variable "image_name" {
  description = "Name of the shared image definition"
  type        = string
  default     = "ubuntu-template"
}

variable "image_version" {
  description = "Shared image version name"
  type        = string
  default     = "1.0.0"
}

variable "source_managed_image_id" {
  description = "Optional source managed image ID used to create the shared image version. When null, only the gallery and image definition are created."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to Azure resources"
  type        = map(string)
  default     = {}
}
