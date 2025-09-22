terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_instance" "game_server" {
  plan     = var.plan_id
  region   = var.region
  os_id    = 387  # Ubuntu 22.04
  ssh_key_ids = [var.ssh_key_id]
  
  user_data = file("${path.module}/user_data.sh")
  
  tags = [
    "game-server",
    var.game_type,
    var.environment
  ]
}

resource "vultr_firewall_group" "game_firewall" {
  description = "Firewall for ${var.game_type} server"
}

resource "vultr_firewall_rule" "game_ports" {
  firewall_group_id = vultr_firewall_group.game_firewall.id
  
  for_each = local.game_ports[var.game_type]
  
  protocol = each.value.protocol
  port     = each.value.port
  source   = "0.0.0.0/0"
  notes    = "${var.game_type} ${each.value.protocol} port ${each.value.port}"
}

locals {
  game_ports = {
    "minecraft" = [
      { port = "25565", protocol = "tcp" },
      { port = "25565", protocol = "udp" }
    ]
    "sotf" = [
      { port = "8766", protocol = "tcp" },
      { port = "8766", protocol = "udp" }
    ]
    "valheim" = [
      { port = "2456", protocol = "tcp" },
      { port = "2456", protocol = "udp" }
    ]
    "rust" = [
      { port = "28015", protocol = "tcp" },
      { port = "28015", protocol = "udp" }
    ]
    "ark" = [
      { port = "7777", protocol = "tcp" },
      { port = "7777", protocol = "udp" }
    ]
  }
}

output "server_ip" {
  description = "IP público do servidor de jogo"
  value       = vultr_instance.game_server.main_ip
}

output "server_id" {
  description = "ID da instância Vultr"
  value       = vultr_instance.game_server.id
}