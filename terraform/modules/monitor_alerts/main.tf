resource "azurerm_monitor_action_group" "main" {
  name                = "${var.target_resource_name}-alerts-ag"
  resource_group_name = var.resource_group_name
  short_name          = "vmss-alerts"
  enabled             = var.enabled
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.email_receivers

    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }
}

resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "${var.target_resource_name}-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.target_resource_id]
  description         = "Alert when average VMSS CPU is above ${var.cpu_threshold}% for 5 minutes."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = var.enabled
  auto_mitigate       = true
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_metric_alert" "low_memory" {
  name                = "${var.target_resource_name}-low-memory"
  resource_group_name = var.resource_group_name
  scopes              = [var.target_resource_id]
  description         = "Alert when available VMSS memory is below ${var.available_memory_threshold}% for 5 minutes."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = var.enabled
  auto_mitigate       = true
  tags                = var.tags

  criteria {
    metric_namespace       = "azure.vm.linux.guestmetrics"
    metric_name            = "Available Memory Percentage"
    aggregation            = "Average"
    operator               = "LessThan"
    threshold              = var.available_memory_threshold
    skip_metric_validation = true
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
