output "network_security_group_id" {
  description = "ID of the VMSS network security group"
  value       = azurerm_network_security_group.main.id
}

output "vmss_id" {
  description = "ID of the Linux VM scale set"
  value       = azurerm_linux_virtual_machine_scale_set.main.id
}

output "source_image_id" {
  description = "Image ID used by the Linux VM scale set. Null means the marketplace source_image_reference was used."
  value       = azurerm_linux_virtual_machine_scale_set.main.source_image_id
}

output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_nat_port_range" {
  description = "Load balancer public port range for SSH to VMSS instances"
  value       = "${azurerm_lb_nat_rule.ssh.frontend_port_start}-${azurerm_lb_nat_rule.ssh.frontend_port_end}"
}
