resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "internal-vmss"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = "Standard_B2ts_v2"
  instances                       = 2
  admin_username                  = var.admin_username
  disable_password_authentication = true
  tags                            = var.tags

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # OS Disk 
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  boot_diagnostics {
    storage_account_uri = null
  }



  # Authentication 
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Network (nic)
  network_interface {
    name                      = "vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.main.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.main.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_rule.ssh.id]
    }
  }

  # nginx via cloud-init for LB healthy backend on port 80.
  custom_data = filebase64("${path.module}/scripts/cloud-init.yaml")

  lifecycle {
    ignore_changes = [instances]
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "azure_monitor_agent" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.main.id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.0"
  auto_upgrade_minor_version   = true
  automatic_upgrade_enabled    = true
}

resource "azurerm_monitor_data_collection_rule" "vmss_guest_metrics" {
  name                = "vmss-guest-metrics-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
  description         = "Collect Linux guest memory metrics for VMSS autoscaling."
  tags                = var.tags

  data_sources {
    performance_counter {
      name                          = "linux-memory-counters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\Memory\\Available MBytes"]
    }
  }

  destinations {
    azure_monitor_metrics {
      name = "azure-monitor-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["azure-monitor-metrics"]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vmss_guest_metrics" {
  name                    = "vmss-guest-metrics-association"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.main.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vmss_guest_metrics.id

  depends_on = [
    azurerm_virtual_machine_scale_set_extension.azure_monitor_agent
  ]
}


# 2. Add Autoscale settings
resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "autoscale-config"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id
  tags                = var.tags


  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      minimum = 1
      maximum = 5
    }

    # Scale out rule: CPU > 70%
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    # Scale out rule: Available memory < 25%
    rule {
      metric_trigger {
        metric_name        = "Available Memory Percentage"
        metric_namespace   = "azure.vm.linux.guestmetrics"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Min"
        time_window        = "PT5M"
        time_aggregation   = "Minimum"
        operator           = "LessThan"
        threshold          = 25
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale in rule: CPU < 30%
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    # Scale in rule: Available memory > 60%
    rule {
      metric_trigger {
        metric_name        = "Available Memory Percentage"
        metric_namespace   = "azure.vm.linux.guestmetrics"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 60
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}

# PublicIPAddress
resource "azurerm_public_ip" "main" {
  name                = "vmss-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "vmss-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

# Backend Pool 
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_nat_rule" "ssh" {
  name                           = "ssh-nat-rule"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.main.id
  protocol                       = "Tcp"
  frontend_port_start            = 50022
  frontend_port_end              = 50031
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  frontend_ip_configuration_name = "PublicIPAddress"

  depends_on = [azurerm_lb_backend_address_pool.main]
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-probe"
  protocol        = "Tcp"
  port            = 80

  depends_on = [azurerm_lb_nat_rule.ssh]
}

# LB Rule 
resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id

  depends_on = [
    azurerm_lb_backend_address_pool.main,
    azurerm_lb_nat_rule.ssh,
    azurerm_lb_probe.http,
  ]
}
