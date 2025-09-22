# Variáveis do módulo VPS Base

variable "do_token" {
  description = "Token de API do DigitalOcean"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "ID da chave SSH no DigitalOcean"
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
  description = "Região do DigitalOcean"
  type        = string
  default     = "nyc3"
}

variable "instance_size" {
  description = "Tamanho da instância"
  type        = string
  default     = "s-2vcpu-8gb"
}

variable "image" {
  description = "Imagem do sistema operacional"
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "game_ports" {
  description = "Lista de portas específicas do jogo"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}
