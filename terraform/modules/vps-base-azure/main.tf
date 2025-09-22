# Módulo específico para Azure Virtual Machines
# Suporta provisionamento de VMs na Azure

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configuração do provedor Azure
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "game_server_rg" {
  name     = "${var.server_name}-${var.game_type}-rg"
  location = var.region

  tags = {
    Name        = "${var.server_name}-${var.game_type}-rg"
    Type        = "game-server"
    Game        = var.game_type
    Environment = var.environment
  }
}

# Virtual Network
resource "azurerm_virtual_network" "game_server_vnet" {
  name                = "${var.server_name}-${var.game_type}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.game_server_rg.location
  resource_group_name = azurerm_resource_group.game_server_rg.name

  tags = {
    Name = "${var.server_name}-${var.game_type}-vnet"
    Type = "game-server"
  }
}

# Subnet
resource "azurerm_subnet" "game_server_subnet" {
  name                 = "${var.server_name}-${var.game_type}-subnet"
  resource_group_name  = azurerm_resource_group.game_server_rg.name
  virtual_network_name = azurerm_virtual_network.game_server_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "game_server_nsg" {
  name                = "${var.game_type}-${var.server_name}-nsg"
  location            = azurerm_resource_group.game_server_rg.location
  resource_group_name = azurerm_resource_group.game_server_rg.name

  # SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Portas específicas do jogo
  dynamic "security_rule" {
    for_each = var.game_ports
    content {
      name                       = "${security_rule.value.protocol}-${security_rule.value.port}"
      priority                   = 1000 + security_rule.key + 10
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = title(security_rule.value.protocol)
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = {
    Name = "${var.game_type}-${var.server_name}-nsg"
    Type = "game-server"
  }
}

# Public IP
resource "azurerm_public_ip" "game_server_pip" {
  name                = "${var.server_name}-${var.game_type}-pip"
  resource_group_name = azurerm_resource_group.game_server_rg.name
  location            = azurerm_resource_group.game_server_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = "${var.server_name}-${var.game_type}-pip"
    Type = "game-server"
  }
}

# Network Interface
resource "azurerm_network_interface" "game_server_nic" {
  name                = "${var.server_name}-${var.game_type}-nic"
  location            = azurerm_resource_group.game_server_rg.location
  resource_group_name = azurerm_resource_group.game_server_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.game_server_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.game_server_pip.id
  }

  tags = {
    Name = "${var.server_name}-${var.game_type}-nic"
    Type = "game-server"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "game_server_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.game_server_nic.id
  network_security_group_id = azurerm_network_security_group.game_server_nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "game_server" {
  name                = "${var.server_name}-${var.game_type}"
  resource_group_name = azurerm_resource_group.game_server_rg.name
  location            = azurerm_resource_group.game_server_rg.location
  size                = var.instance_size
  admin_username      = "azureuser"

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.game_server_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${var.ssh_public_key_path}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/user_data.sh", {
    game_type = var.game_type
  }))

  tags = {
    Name        = "${var.server_name}-${var.game_type}"
    Type        = "game-server"
    Game        = var.game_type
    Environment = var.environment
  }
}

# Managed Identity para Azure Monitor
resource "azurerm_user_assigned_identity" "game_server_identity" {
  count               = var.enable_monitoring ? 1 : 0
  location            = azurerm_resource_group.game_server_rg.location
  name                = "${var.server_name}-${var.game_type}-identity"
  resource_group_name = azurerm_resource_group.game_server_rg.name

  tags = {
    Name = "${var.server_name}-${var.game_type}-identity"
    Type = "game-server"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "game_server_workspace" {
  count               = var.enable_monitoring ? 1 : 0
  name                = "${var.server_name}-${var.game_type}-workspace"
  location            = azurerm_resource_group.game_server_rg.location
  resource_group_name = azurerm_resource_group.game_server_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = {
    Name = "${var.server_name}-${var.game_type}-workspace"
    Type = "game-server"
  }
}

# Azure Monitor Agent Extension
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.game_server.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    workspaceId = azurerm_log_analytics_workspace.game_server_workspace[0].workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = azurerm_log_analytics_workspace.game_server_workspace[0].primary_shared_key
  })

  tags = {
    Name = "${var.server_name}-${var.game_type}-monitor"
    Type = "game-server"
  }
}

# Outputs
output "server_ip" {
  description = "IP público do servidor"
  value       = azurerm_public_ip.game_server_pip.ip_address
}

output "server_id" {
  description = "ID da VM"
  value       = azurerm_linux_virtual_machine.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = azurerm_linux_virtual_machine.game_server.name
}

output "private_ip" {
  description = "IP privado do servidor"
  value       = azurerm_network_interface.game_server_nic.private_ip_address
}

output "resource_group_name" {
  description = "Nome do Resource Group"
  value       = azurerm_resource_group.game_server_rg.name
}
