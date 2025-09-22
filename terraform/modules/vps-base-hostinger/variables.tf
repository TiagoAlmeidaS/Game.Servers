# Variáveis do módulo VPS Base para Hostinger

variable "hostinger_api_key" {
  description = "API Key da Hostinger"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "ID da chave SSH na Hostinger"
  type        = string
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
  description = "Região da Hostinger"
  type        = string
  default     = "amsterdam"
}

variable "instance_size" {
  description = "Tamanho da instância Hostinger"
  type        = string
  default     = "vps-1"
}

variable "game_ports" {
  description = "Lista de portas específicas do jogo"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}
