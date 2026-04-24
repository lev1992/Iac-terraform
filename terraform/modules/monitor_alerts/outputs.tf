output "action_group_id" {
  description = "ID of the Azure Monitor action group"
  value       = azurerm_monitor_action_group.main.id
}

output "high_cpu_alert_id" {
  description = "ID of the high CPU metric alert"
  value       = azurerm_monitor_metric_alert.high_cpu.id
}

output "low_memory_alert_id" {
  description = "ID of the low memory metric alert"
  value       = azurerm_monitor_metric_alert.low_memory.id
}
