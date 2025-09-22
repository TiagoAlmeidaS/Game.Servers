# Variáveis do módulo VPS Base para Vultr

variable "vultr_api_key" {
  description = "API Key do Vultr"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "ID da chave SSH no Vultr"
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
  description = "Região do Vultr"
  type        = string
  default     = "ewr"
}

variable "instance_size" {
  description = "Tamanho da instância Vultr"
  type        = string
  default     = "vc2-1c-1gb"
}

variable "disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 25
}

variable "enable_ipv6" {
  description = "Habilitar IPv6"
  type        = bool
  default     = true
}

variable "enable_backups" {
  description = "Habilitar backups automáticos"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Habilitar monitoramento"
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
