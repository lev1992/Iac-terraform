output "vmss_id" {
  description = "ID of the Linux VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.id
}

output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.main.ip_address
}
