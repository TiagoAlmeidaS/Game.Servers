# Módulo de firewall específico para jogos
# Define regras de firewall baseadas no tipo de jogo

locals {
  # Portas padrão por tipo de jogo
  game_ports = {
    "sotf" = [
      { port = "8766", protocol = "tcp" },
      { port = "8766", protocol = "udp" }
    ]
    "minecraft" = [
      { port = "25565", protocol = "tcp" },
      { port = "25565", protocol = "udp" }
    ]
    "valheim" = [
      { port = "2456", protocol = "tcp" },
      { port = "2456", protocol = "udp" },
      { port = "2457", protocol = "tcp" },
      { port = "2457", protocol = "udp" }
    ]
    "rust" = [
      { port = "28015", protocol = "tcp" },
      { port = "28015", protocol = "udp" },
      { port = "28016", protocol = "tcp" },
      { port = "28016", protocol = "udp" }
    ]
    "ark" = [
      { port = "7777", protocol = "tcp" },
      { port = "7777", protocol = "udp" },
      { port = "7778", protocol = "tcp" },
      { port = "7778", protocol = "udp" },
      { port = "27015", protocol = "tcp" },
      { port = "27015", protocol = "udp" }
    ]
  }
}

# Firewall principal
resource "digitalocean_firewall" "game_firewall" {
  name        = "${var.game_type}-firewall-${var.server_name}"
  droplet_ids = var.droplet_ids

  # SSH (sempre necessário)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  # Portas específicas do jogo
  dynamic "inbound_rule" {
    for_each = lookup(local.game_ports, var.game_type, [])
    content {
      protocol         = inbound_rule.value.protocol
      port_range       = inbound_rule.value.port
      source_addresses = ["0.0.0.0/0"]
    }
  }

  # Portas customizadas adicionais
  dynamic "inbound_rule" {
    for_each = var.custom_ports
    content {
      protocol         = inbound_rule.value.protocol
      port_range       = inbound_rule.value.port
      source_addresses = ["0.0.0.0/0"]
    }
  }

  # Outbound rules (permitir tudo)
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Outputs
output "firewall_id" {
  description = "ID do firewall criado"
  value       = digitalocean_firewall.game_firewall.id
}

output "firewall_name" {
  description = "Nome do firewall"
  value       = digitalocean_firewall.game_firewall.name
}
