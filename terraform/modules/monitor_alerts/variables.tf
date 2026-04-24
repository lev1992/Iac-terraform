variable "resource_group_name" {
  description = "Name of the resource group where alerts will be created"
  type        = string
}

variable "target_resource_id" {
  description = "Azure resource ID that metric alerts will monitor"
  type        = string
}

variable "target_resource_name" {
  description = "Friendly name of the monitored resource for alert naming"
  type        = string
}

variable "email_receivers" {
  description = "Email receivers for the Azure Monitor action group"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "cpu_threshold" {
  description = "Average CPU percentage that triggers a high CPU alert"
  type        = number
  default     = 70
}

variable "available_memory_threshold" {
  description = "Available memory percentage below which the memory alert triggers"
  type        = number
  default     = 25
}

variable "enabled" {
  description = "Whether monitor alerts are enabled"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to Azure Monitor resources"
  type        = map(string)
  default     = {}
}
