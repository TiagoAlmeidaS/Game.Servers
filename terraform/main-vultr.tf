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

module "vps_base" {
  source = "./modules/vps-base-vultr"
  
  vultr_api_key = var.vultr_api_key
  ssh_key_id    = var.ssh_key_id
  region        = var.region
  plan_id       = var.plan_id
  game_type     = var.game_type
  server_name   = var.server_name
  max_players   = var.max_players
  environment   = var.environment
}

output "server_ip" {
  description = "IP público do servidor de jogo"
  value       = module.vps_base.server_ip
}

output "server_id" {
  description = "ID da instância Vultr"
  value       = module.vps_base.server_id
}
