output "vmss_id" {
  description = "ID of the Linux VM scale set"
  value       = module.my_vmss.vmss_id
}

output "public_ip_address" {
  description = "Public IP address of the load balancer"
  value       = module.my_vmss.public_ip_address
}

output "vmss_source_image_id" {
  description = "Shared Image Gallery image version ID used by the VMSS. Null means the marketplace image fallback was used."
  value       = module.my_vmss.source_image_id
}

output "compute_gallery_id" {
  description = "ID of the Azure Compute Gallery"
  value       = module.image.gallery_id
}

output "shared_image_definition_id" {
  description = "ID of the shared image definition"
  value       = module.image.image_definition_id
}

output "shared_image_version_id" {
  description = "ID of the shared image version. Null until shared_image_source_managed_image_id is set."
  value       = module.image.image_version_id
}

output "ssh_nat_port_range" {
  description = "Load balancer public port range for SSH to VMSS instances"
  value       = module.my_vmss.ssh_nat_port_range
}

output "monitor_action_group_id" {
  description = "ID of the Azure Monitor action group"
  value       = module.monitor_alerts.action_group_id
}

output "high_cpu_alert_id" {
  description = "ID of the high CPU metric alert"
  value       = module.monitor_alerts.high_cpu_alert_id
}

output "low_memory_alert_id" {
  description = "ID of the low memory metric alert"
  value       = module.monitor_alerts.low_memory_alert_id
}
