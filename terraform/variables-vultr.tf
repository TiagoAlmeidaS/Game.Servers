variable "vultr_api_key" {
  description = "API Key do Vultr"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "ID da chave SSH no Vultr"
  type        = string
}

variable "region" {
  description = "Região do Vultr"
  type        = string
  default     = "sao-paulo"
}

variable "plan_id" {
  description = "ID do plano Vultr"
  type        = string
  default     = "vc2-1c-1gb"
}

variable "game_type" {
  description = "Tipo de jogo"
  type        = string
  default     = "minecraft"
}

variable "server_name" {
  description = "Nome do servidor"
  type        = string
  default     = "GameServer"
}

variable "max_players" {
  description = "Número máximo de jogadores"
  type        = number
  default     = 10
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}
