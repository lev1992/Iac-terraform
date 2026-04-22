output "network_security_group_id" {
  description = "ID of the VMSS network security group"
  value       = azurerm_network_security_group.main.id
}
