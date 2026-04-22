variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
}