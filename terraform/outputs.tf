output "vmss_id" {
  description = "ID of the Linux VM scale set"
  value       = module.my_vmss.vmss_id
}

output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = module.my_vmss.public_ip_address
}
