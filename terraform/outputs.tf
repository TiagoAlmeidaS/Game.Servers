# Outputs do Game.Servers

output "server_ip" {
  description = "IP público do servidor de jogo"
  value       = module.vps_base.server_ip
}

output "server_name" {
  description = "Nome do servidor"
  value       = module.vps_base.server_name
}

output "server_id" {
  description = "ID do droplet no DigitalOcean"
  value       = module.vps_base.server_id
}

output "firewall_id" {
  description = "ID do firewall"
  value       = module.firewall.firewall_id
}

output "connection_info" {
  description = "Informações de conexão para o jogo"
  value = {
    ip          = module.vps_base.server_ip
    game_type   = var.game_type
    port        = local.game_port
    server_name = var.server_name
  }
}

# Porta padrão do jogo
locals {
  game_ports_map = {
    "sotf"      = "8766"
    "minecraft" = "25565"
    "valheim"   = "2456"
    "rust"      = "28015"
    "ark"       = "7777"
  }
  game_port = lookup(local.game_ports_map, var.game_type, "8766")
}
