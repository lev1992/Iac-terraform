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
  type        = string
  description = "Optional managed image ID used to create the shared image version."
  default     = null
}
