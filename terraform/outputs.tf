output "vmss_id" {
  description = "ID of the Linux VM scale set"
  value       = module.my_vmss.vmss_id
}

output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = module.my_vmss.public_ip_address
}

output "ssh_nat_port_range" {
  description = "Load balancer public port range for SSH to VMSS instances"
  value       = module.my_vmss.ssh_nat_port_range
}
