# Variáveis do módulo VPS Base para AWS

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Nome da chave SSH na AWS (Key Pair)"
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
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_size" {
  description = "Tamanho da instância EC2"
  type        = string
  default     = "t3.medium"
}

variable "disk_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 20
}

variable "assign_eip" {
  description = "Atribuir Elastic IP"
  type        = bool
  default     = true
}

variable "game_ports" {
  description = "Lista de portas específicas do jogo"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}

variable "enable_cloudwatch" {
  description = "Habilitar CloudWatch logs"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Habilitar monitoramento detalhado"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 7
}
