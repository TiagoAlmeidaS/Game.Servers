# Variáveis universais do Game.Servers
# Suporta múltiplos provedores de cloud

# ===========================================
# CONFIGURAÇÃO DO PROVEDOR
# ===========================================

variable "provider" {
  description = "Provedor de cloud (digitalocean, hostinger, aws, azure, linode, vultr)"
  type        = string
  default     = "digitalocean"
  validation {
    condition = contains([
      "digitalocean", "hostinger", "aws", "azure", "linode", "vultr"
    ], var.provider)
    error_message = "Provedor deve ser: digitalocean, hostinger, aws, azure, linode ou vultr."
  }
}

# ===========================================
# CONFIGURAÇÃO DO SERVIDOR
# ===========================================

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

# ===========================================
# CONFIGURAÇÃO DA INFRAESTRUTURA
# ===========================================

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
  description = "Região do provedor"
  type        = string
  default     = "nyc3"
}

variable "instance_size" {
  description = "Tamanho da instância"
  type        = string
  default     = "s-2vcpu-8gb"
}

# ===========================================
# CREDENCIAIS POR PROVEDOR
# ===========================================

# DigitalOcean
variable "do_token" {
  description = "Token de API do DigitalOcean"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_key_id" {
  description = "ID da chave SSH (DigitalOcean, Hostinger, Linode, Vultr)"
  type        = string
  default     = ""
}

# Hostinger
variable "hostinger_api_key" {
  description = "API Key da Hostinger"
  type        = string
  sensitive   = true
  default     = ""
}

# AWS
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_key_name" {
  description = "Nome da chave SSH (AWS, Azure)"
  type        = string
  default     = ""
}

# Azure
variable "azure_client_id" {
  description = "Azure Client ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
  default     = ""
}

# Linode
variable "linode_token" {
  description = "Token de API do Linode"
  type        = string
  sensitive   = true
  default     = ""
}

# Vultr
variable "vultr_api_key" {
  description = "API Key do Vultr"
  type        = string
  sensitive   = true
  default     = ""
}

# ===========================================
# CONFIGURAÇÕES AVANÇADAS
# ===========================================

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

variable "ssh_private_key_path" {
  description = "Caminho para a chave SSH privada"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# ===========================================
# CONFIGURAÇÕES ESPECÍFICAS POR JOGO
# ===========================================

# Minecraft
variable "minecraft_difficulty" {
  description = "Dificuldade do Minecraft"
  type        = string
  default     = "normal"
  validation {
    condition     = contains(["peaceful", "easy", "normal", "hard"], var.minecraft_difficulty)
    error_message = "Dificuldade do Minecraft deve ser: peaceful, easy, normal ou hard."
  }
}

variable "minecraft_gamemode" {
  description = "Modo de jogo do Minecraft"
  type        = string
  default     = "survival"
  validation {
    condition     = contains(["survival", "creative", "adventure", "spectator"], var.minecraft_gamemode)
    error_message = "Modo de jogo do Minecraft deve ser: survival, creative, adventure ou spectator."
  }
}

variable "minecraft_level_type" {
  description = "Tipo de mundo do Minecraft"
  type        = string
  default     = "minecraft:normal"
}

variable "minecraft_seed" {
  description = "Seed do mundo do Minecraft"
  type        = string
  default     = ""
}

# Sons of the Forest
variable "sotf_difficulty" {
  description = "Dificuldade do Sons of the Forest"
  type        = string
  default     = "Normal"
  validation {
    condition     = contains(["Peaceful", "Normal", "Hard"], var.sotf_difficulty)
    error_message = "Dificuldade do SotF deve ser: Peaceful, Normal ou Hard."
  }
}

variable "sotf_enable_pvp" {
  description = "Habilitar PvP no Sons of the Forest"
  type        = bool
  default     = true
}

variable "sotf_enable_cheats" {
  description = "Habilitar cheats no Sons of the Forest"
  type        = bool
  default     = false
}

# Valheim
variable "valheim_world_name" {
  description = "Nome do mundo do Valheim"
  type        = string
  default     = "Dedicated"
}

variable "valheim_password" {
  description = "Senha do servidor Valheim"
  type        = string
  sensitive   = true
  default     = ""
}

# Rust
variable "rust_server_name" {
  description = "Nome do servidor Rust"
  type        = string
  default     = "Rust Server"
}

variable "rust_server_description" {
  description = "Descrição do servidor Rust"
  type        = string
  default     = "Rust server hosted with Game.Servers"
}

# ARK
variable "ark_server_name" {
  description = "Nome do servidor ARK"
  type        = string
  default     = "ARK Server"
}

variable "ark_server_password" {
  description = "Senha do servidor ARK"
  type        = string
  sensitive   = true
  default     = ""
}

# ===========================================
# CONFIGURAÇÕES DE MONITORAMENTO
# ===========================================

variable "enable_monitoring" {
  description = "Habilitar monitoramento"
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Email para alertas"
  type        = string
  default     = ""
}

variable "slack_webhook" {
  description = "Webhook do Slack para notificações"
  type        = string
  sensitive   = true
  default     = ""
}

variable "discord_webhook" {
  description = "Webhook do Discord para notificações"
  type        = string
  sensitive   = true
  default     = ""
}

# ===========================================
# CONFIGURAÇÕES DE BACKUP
# ===========================================

variable "enable_backup" {
  description = "Habilitar backup automático"
  type        = bool
  default     = true
}

variable "backup_interval" {
  description = "Intervalo de backup em horas"
  type        = number
  default     = 24
}

variable "backup_retention" {
  description = "Retenção de backups em dias"
  type        = number
  default     = 7
}

# ===========================================
# CONFIGURAÇÕES DE SEGURANÇA
# ===========================================

variable "enable_whitelist" {
  description = "Habilitar whitelist (Minecraft)"
  type        = bool
  default     = false
}

variable "enable_online_mode" {
  description = "Habilitar modo online (Minecraft)"
  type        = bool
  default     = true
}

variable "enable_pvp" {
  description = "Habilitar PvP"
  type        = bool
  default     = true
}

variable "enable_cheats" {
  description = "Habilitar cheats"
  type        = bool
  default     = false
}
