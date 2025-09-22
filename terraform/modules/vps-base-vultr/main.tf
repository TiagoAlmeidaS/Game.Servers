# Módulo específico para Vultr
# Suporta provisionamento de instâncias Vultr

terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
}

# Configuração do provedor Vultr
provider "vultr" {
  api_key = var.vultr_api_key
}

# Instância Vultr
resource "vultr_instance" "game_server" {
  plan       = var.instance_size
  region     = var.region
  os_id      = 387  # Ubuntu 22.04 LTS
  ssh_key_id = var.ssh_key_id

  # User data para configuração inicial
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    game_type = var.game_type
  }))

  # Configurações de storage
  disk = var.disk_size

  # Configurações de rede
  enable_ipv6 = var.enable_ipv6

  # Configurações de backup
  backups = var.enable_backups

  # Configurações de monitoramento
  monitoring = var.enable_monitoring

  # Tags
  tags = [
    "game-server",
    var.game_type,
    var.environment
  ]

  # Configurações de firewall
  firewall_group_id = vultr_firewall_group.game_server_firewall.id
}

# Firewall Group
resource "vultr_firewall_group" "game_server_firewall" {
  description = "Firewall for ${var.game_type} game server"
}

# Firewall Rules
resource "vultr_firewall_rule" "ssh" {
  firewall_group_id = vultr_firewall_group.game_server_firewall.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "22"
  notes             = "SSH access"
}

# Portas específicas do jogo
resource "vultr_firewall_rule" "game_ports" {
  for_each = { for port in var.game_ports : "${port.protocol}-${port.port}" => port }

  firewall_group_id = vultr_firewall_group.game_server_firewall.id
  protocol          = upper(each.value.protocol)
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = each.value.port
  notes             = "${each.value.protocol} port ${each.value.port}"
}

# Load Balancer (opcional)
resource "vultr_load_balancer" "game_server_lb" {
  count = var.enable_load_balancer ? 1 : 0

  region = var.region
  label  = "${var.server_name}-${var.game_type}-lb"

  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port     = var.load_balancer_port
    backend_protocol  = "tcp"
    backend_port      = var.load_balancer_port
  }

  health_check {
    protocol = "tcp"
    port     = var.load_balancer_port
    path     = "/"
    interval = 15
    timeout  = 5
    unhealthy_threshold = 5
    healthy_threshold   = 3
  }

  instances = [vultr_instance.game_server.id]

  tags = [
    "game-server",
    var.game_type,
    "load-balancer"
  ]
}

# Outputs
output "server_ip" {
  description = "IP público do servidor"
  value       = vultr_instance.game_server.main_ip
}

output "server_id" {
  description = "ID da instância Vultr"
  value       = vultr_instance.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = vultr_instance.game_server.label
}

output "private_ip" {
  description = "IP privado do servidor"
  value       = vultr_instance.game_server.internal_ip
}

output "load_balancer_ip" {
  description = "IP do Load Balancer"
  value       = var.enable_load_balancer ? vultr_load_balancer.game_server_lb[0].ipv4 : null
}
