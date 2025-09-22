# Variáveis do módulo VPS Base para Azure

variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave SSH pública"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
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
  description = "Região da Azure"
  type        = string
  default     = "East US"
}

variable "instance_size" {
  description = "Tamanho da instância Azure"
  type        = string
  default     = "Standard_B2s"
}

variable "disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 30
}

variable "enable_monitoring" {
  description = "Habilitar Azure Monitor"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no Azure Monitor"
  type        = number
  default     = 30
}

variable "game_ports" {
  description = "Lista de portas específicas do jogo"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}
