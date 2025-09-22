# Módulo específico para Hostinger VPS
# Suporta provisionamento de VPS na Hostinger

terraform {
  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 1.0"
    }
  }
}

# Configuração do provedor Hostinger
provider "hostinger" {
  api_key = var.hostinger_api_key
}

# VPS Hostinger
resource "hostinger_vps" "game_server" {
  name     = "${var.server_name}-${var.game_type}"
  region   = var.region
  plan     = var.instance_size
  ssh_key  = var.ssh_key_id
  os       = "ubuntu-22.04"

  # User data para configuração inicial
  user_data = templatefile("${path.module}/user_data.sh", {
    game_type = var.game_type
  })

  tags = [
    "game-server",
    var.game_type,
    var.environment
  ]
}

# Firewall específico para o jogo
resource "hostinger_firewall" "game_firewall" {
  vps_id = hostinger_vps.game_server.id
  name   = "${var.game_type}-firewall-${var.server_name}"

  # SSH
  rule {
    protocol = "tcp"
    port     = "22"
    source   = "0.0.0.0/0"
    action   = "allow"
  }

  # Portas específicas do jogo
  dynamic "rule" {
    for_each = var.game_ports
    content {
      protocol = rule.value.protocol
      port     = rule.value.port
      source   = "0.0.0.0/0"
      action   = "allow"
    }
  }
}

# Outputs
output "server_ip" {
  description = "IP público do servidor"
  value       = hostinger_vps.game_server.public_ip
}

output "server_id" {
  description = "ID do VPS"
  value       = hostinger_vps.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = hostinger_vps.game_server.name
}
