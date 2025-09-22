# Configuração principal do Game.Servers para Hostinger
# Provisiona VPS e configura servidor de jogo

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Provider Hostinger
provider "hostinger" {
  api_key = var.hostinger_api_key
}

# Módulo VPS Base para Hostinger
module "vps_base" {
  source = "./modules/vps-base-hostinger"

  hostinger_api_key = var.hostinger_api_key
  ssh_key_id        = var.ssh_key_id
  server_name       = var.server_name
  game_type         = var.game_type
  environment       = var.environment
  region            = var.region
  instance_size     = var.instance_size
  game_ports        = var.game_ports
}

# Configuração do servidor via Ansible
resource "null_resource" "configure_game_server" {
  depends_on = [module.vps_base]

  # Trigger para reconfigurar quando variáveis mudarem
  triggers = {
    server_ip       = module.vps_base.server_ip
    game_type       = var.game_type
    server_name     = var.server_name
    server_password = var.server_password
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ../ansible
      ansible-playbook \
        -i ${module.vps_base.server_ip}, \
        playbooks/deploy-game.yml \
        --extra-vars "game_type=${var.game_type}" \
        --extra-vars "server_name=${var.server_name}" \
        --extra-vars "server_password=${var.server_password}" \
        --extra-vars "max_players=${var.max_players}" \
        --extra-vars "server_ip=${module.vps_base.server_ip}" \
        --user=root \
        --private-key=${var.ssh_private_key_path}
    EOT
  }

  # Cleanup quando destruir
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      cd ../ansible
      ansible-playbook \
        -i ${self.triggers.server_ip}, \
        playbooks/cleanup-game.yml \
        --extra-vars "game_type=${self.triggers.game_type}" \
        --user=root \
        --private-key=${var.ssh_private_key_path}
    EOT
  }
}
