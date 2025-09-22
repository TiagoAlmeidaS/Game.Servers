# Variáveis do módulo VPS Base para Linode

variable "linode_token" {
  description = "Token de API do Linode"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Chave SSH pública"
  type        = string
}

variable "root_password" {
  description = "Senha root da instância"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Nome do servidor"
  type        = string
  default     = "game-server"
}

variable "game_type" {
  description = "Tipo do jogo (sotf, minecraft, valheim, etc.)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Região do Linode"
  type        = string
  default     = "us-east"
}

variable "instance_size" {
  description = "Tamanho da instância Linode"
  type        = string
  default     = "g6-nanode-1"
}

variable "disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 25
}

variable "enable_backups" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "enable_watchdog" {
  description = "Habilitar watchdog"
  type        = bool
  default     = true
}

variable "enable_load_balancer" {
  description = "Habilitar Load Balancer"
  type        = bool
  default     = false
}

variable "load_balancer_port" {
  description = "Porta do Load Balancer"
  type        = string
  default     = "8766"
}

variable "game_ports" {
  description = "Lista de portas específicas do jogo"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}
