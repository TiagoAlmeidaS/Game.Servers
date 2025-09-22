# Módulo específico para Linode
# Suporta provisionamento de instâncias Linode

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 1.0"
    }
  }
}

# Configuração do provedor Linode
provider "linode" {
  token = var.linode_token
}

# Instância Linode
resource "linode_instance" "game_server" {
  label           = "${var.server_name}-${var.game_type}"
  image           = "linode/ubuntu22.04"
  region          = var.region
  type            = var.instance_size
  authorized_keys = [var.ssh_public_key]
  root_pass       = var.root_password

  # User data para configuração inicial
  metadata = {
    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
      game_type = var.game_type
    }))
  }

  # Configurações de storage
  disk {
    label      = "boot"
    size       = var.disk_size
    filesystem = "ext4"
    image      = "linode/ubuntu22.04"
  }

  # Configurações de swap
  disk {
    label = "swap"
    size  = 512
    filesystem = "swap"
  }

  # Configurações de rede
  interface {
    purpose = "public"
  }

  interface {
    purpose = "vlan"
    label   = "${var.server_name}-${var.game_type}-vlan"
  }

  tags = [
    "game-server",
    var.game_type,
    var.environment
  ]

  # Configurações de backup
  backups_enabled = var.enable_backups

  # Configurações de monitoramento
  watchdog_enabled = var.enable_watchdog
}

# Firewall para o servidor de jogo
resource "linode_firewall" "game_server_firewall" {
  label = "${var.game_type}-${var.server_name}-firewall"

  # SSH
  inbound {
    label    = "ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    addresses = ["0.0.0.0/0"]
  }

  # Portas específicas do jogo
  dynamic "inbound" {
    for_each = var.game_ports
    content {
      label     = "${inbound.value.protocol}-${inbound.value.port}"
      action    = "ACCEPT"
      protocol  = upper(inbound.value.protocol)
      ports     = inbound.value.port
      addresses = ["0.0.0.0/0"]
    }
  }

  # Outbound - permitir tudo
  outbound {
    label    = "outbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "1-65535"
    addresses = ["0.0.0.0/0"]
  }

  outbound {
    label    = "outbound-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "1-65535"
    addresses = ["0.0.0.0/0"]
  }

  # Aplicar firewall à instância
  linodes = [linode_instance.game_server.id]

  tags = [
    "game-server",
    var.game_type
  ]
}

# NodeBalancer (opcional)
resource "linode_nodebalancer" "game_server_lb" {
  count = var.enable_load_balancer ? 1 : 0
  label = "${var.server_name}-${var.game_type}-lb"
  region = var.region

  tags = [
    "game-server",
    var.game_type,
    "load-balancer"
  ]
}

# NodeBalancer Config
resource "linode_nodebalancer_config" "game_server_lb_config" {
  count = var.enable_load_balancer ? 1 : 0
  nodebalancer_id = linode_nodebalancer.game_server_lb[0].id
  port            = var.load_balancer_port
  protocol        = "tcp"
  algorithm       = "roundrobin"
  check           = "connection"
  check_interval  = 30
  check_timeout   = 5
  check_attempts  = 3
  check_path      = "/"
  check_passive   = true
  check_body      = ""
  ssl_cert        = ""
  ssl_key         = ""
  cipher_suite    = "recommended"
  stickiness      = "none"
}

# NodeBalancer Node
resource "linode_nodebalancer_node" "game_server_lb_node" {
  count = var.enable_load_balancer ? 1 : 0
  nodebalancer_id = linode_nodebalancer.game_server_lb[0].id
  config_id       = linode_nodebalancer_config.game_server_lb_config[0].id
  address         = "${linode_instance.game_server.ip_address}:${var.load_balancer_port}"
  label           = "${var.server_name}-${var.game_type}-node"
  weight          = 100
  mode            = "accept"
}

# Outputs
output "server_ip" {
  description = "IP público do servidor"
  value       = linode_instance.game_server.ip_address
}

output "server_id" {
  description = "ID da instância Linode"
  value       = linode_instance.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = linode_instance.game_server.label
}

output "private_ip" {
  description = "IP privado do servidor"
  value       = linode_instance.game_server.private_ip_address
}

output "load_balancer_ip" {
  description = "IP do Load Balancer"
  value       = var.enable_load_balancer ? linode_nodebalancer.game_server_lb[0].ipv4 : null
}
