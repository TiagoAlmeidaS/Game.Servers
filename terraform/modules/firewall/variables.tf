# Variáveis do módulo Firewall

variable "game_type" {
  description = "Tipo do jogo para definir portas"
  type        = string
}

variable "server_name" {
  description = "Nome do servidor"
  type        = string
}

variable "droplet_ids" {
  description = "Lista de IDs dos droplets"
  type        = list(string)
}

variable "custom_ports" {
  description = "Portas customizadas adicionais"
  type = list(object({
    port     = string
    protocol = string
  }))
  default = []
}
