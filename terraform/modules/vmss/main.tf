resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                = "internal-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard_B2ts_v2"
  instances           = 2
  admin_username      = var.admin_username

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

  

  # Authentication 
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Network (nic)
  network_interface {
    name    = "vmss-nic"
    primary = true
    network_security_group_id = azurerm_network_security_group.main.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.main.id]
    }
  }

  # nginx via cloud-init for LB healthy backend on port 80.
  custom_data = filebase64("${path.module}/scripts/cloud-init.yaml")

  lifecycle {
    ignore_changes = [instances]
  }
}


# 2. Add Autoscale settings
resource "azurerm_monitor_autoscale_setting" "main" {
  name                = "autoscale-config"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.main.id


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
  }
}

# PublicIPAddress
resource "azurerm_public_ip" "main" {
  name                = "vmss-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "vmss-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

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

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-probe"
  protocol        = "Tcp"
  port            = 80
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
}


