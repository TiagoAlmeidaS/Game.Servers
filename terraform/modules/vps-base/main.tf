# Módulo genérico para provisionamento de VPS
# Suporta múltiplos provedores (DigitalOcean, AWS, etc.)

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configuração do provedor
provider "digitalocean" {
  token = var.do_token
}

# Droplet/VPS principal
resource "digitalocean_droplet" "game_server" {
  image    = var.image
  name     = "${var.server_name}-${var.game_type}"
  region   = var.region
  size     = var.instance_size
  ssh_keys = [var.ssh_key_id]

  # User data para instalação inicial
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
resource "digitalocean_firewall" "game_firewall" {
  name        = "${var.game_type}-firewall-${var.server_name}"
  droplet_ids = [digitalocean_droplet.game_server.id]

  # SSH
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  # Portas específicas do jogo (definidas por variável)
  dynamic "inbound_rule" {
    for_each = var.game_ports
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
output "server_ip" {
  description = "IP público do servidor"
  value       = digitalocean_droplet.game_server.ipv4_address
}

output "server_id" {
  description = "ID do droplet"
  value       = digitalocean_droplet.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = digitalocean_droplet.game_server.name
}
