# Variáveis principais do Game.Servers

# Credenciais
variable "do_token" {
  description = "Token de API do DigitalOcean"
  type        = string
  sensitive   = true
}

variable "ssh_key_id" {
  description = "ID da chave SSH no DigitalOcean"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Caminho para a chave SSH privada"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# Configuração do servidor
variable "server_name" {
  description = "Nome do servidor de jogo"
  type        = string
  default     = "game-server"
}

variable "game_type" {
  description = "Tipo do jogo (sotf, minecraft, valheim, rust, ark)"
  type        = string
  validation {
    condition = contains([
      "sotf", "minecraft", "valheim", "rust", "ark"
    ], var.game_type)
    error_message = "Tipo de jogo deve ser: sotf, minecraft, valheim, rust ou ark."
  }
}

variable "server_password" {
  description = "Senha do servidor de jogo"
  type        = string
  sensitive   = true
  default     = ""
}

variable "max_players" {
  description = "Número máximo de jogadores"
  type        = number
  default     = 8
}

# Configuração da infraestrutura
variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Ambiente deve ser: dev, staging ou prod."
  }
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

# Portas customizadas
variable "game_ports" {
  description = "Portas específicas do jogo (sobrescreve padrão)"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}

variable "custom_ports" {
  description = "Portas customizadas adicionais"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}
