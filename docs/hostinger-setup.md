# Setup do Game.Servers com Hostinger VPS

Este guia cobre o provisionamento completo de servidores de jogos usando VPS da Hostinger através do Game.Servers.

## 📋 Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.5.0
- **Ansible** >= 2.15.0
- **Git** (para versionamento)
- **SSH** configurado

### Contas e Credenciais
- Conta na Hostinger com API Key
- Chave SSH cadastrada na Hostinger
- Acesso ao painel de controle da Hostinger

## 🔑 Configuração da API da Hostinger

### 1. Obter API Key

1. Acesse o [painel da Hostinger](https://hpanel.hostinger.com/)
2. Vá para **API** no menu lateral
3. Clique em **Generate New API Key**
4. Copie a API Key gerada
5. **IMPORTANTE**: Salve a API Key em local seguro

### 2. Configurar Chave SSH

1. No painel da Hostinger, vá para **SSH Keys**
2. Clique em **Add SSH Key**
3. Cole sua chave SSH pública
4. Dê um nome descritivo (ex: "Game.Servers")
5. Anote o ID da chave SSH

### 3. Verificar Regiões Disponíveis

A Hostinger oferece VPS em várias regiões:
- **Europa**: Amsterdam, London, Frankfurt
- **América**: New York, Los Angeles
- **Ásia**: Singapore, Tokyo

## 🚀 Quick Start com Hostinger

### 1. Configuração Inicial

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/Game.Servers.git
cd Game.Servers

# Configure as variáveis
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

### 2. Editar Configurações para Hostinger

Edite o arquivo `terraform/terraform.tfvars`:

```hcl
# Credenciais Hostinger
hostinger_api_key = "sua-api-key-da-hostinger"
ssh_key_id = "seu-ssh-key-id"

# Configuração do servidor
server_name = "MeuServidorSotF"
game_type = "sotf"
server_password = "minha-senha-segura"
max_players = 8

# Infraestrutura Hostinger
provider = "hostinger"
region = "amsterdam"  # amsterdam, london, frankfurt, newyork, losangeles, singapore, tokyo
instance_size = "vps-1"  # vps-1, vps-2, vps-3, vps-4, vps-5
```

### 3. Deploy do Servidor

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## 🏗️ Adaptação para Hostinger

### Módulo VPS Base para Hostinger

Crie o arquivo `terraform/modules/vps-base-hostinger/main.tf`:

```hcl
# Módulo específico para Hostinger VPS
terraform {
  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 1.0"
    }
  }
}

# Configuração do provedor Hostinger
provider "hostinger" {
  api_key = var.hostinger_api_key
}

# VPS Hostinger
resource "hostinger_vps" "game_server" {
  name     = "${var.server_name}-${var.game_type}"
  region   = var.region
  plan     = var.instance_size
  ssh_key  = var.ssh_key_id
  os       = "ubuntu-22.04"

  # User data para configuração inicial
  user_data = templatefile("${path.module}/user_data.sh", {
    game_type = var.game_type
  })

  tags = [
    "game-server",
    var.game_type,
    var.environment
  ]
}

# Firewall específico para o jogo
resource "hostinger_firewall" "game_firewall" {
  vps_id = hostinger_vps.game_server.id
  name   = "${var.game_type}-firewall-${var.server_name}"

  # SSH
  rule {
    protocol = "tcp"
    port     = "22"
    source   = "0.0.0.0/0"
    action   = "allow"
  }

  # Portas específicas do jogo
  dynamic "rule" {
    for_each = var.game_ports
    content {
      protocol = rule.value.protocol
      port     = rule.value.port
      source   = "0.0.0.0/0"
      action   = "allow"
    }
  }
}

# Outputs
output "server_ip" {
  description = "IP público do servidor"
  value       = hostinger_vps.game_server.public_ip
}

output "server_id" {
  description = "ID do VPS"
  value       = hostinger_vps.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = hostinger_vps.game_server.name
}
```

### Variáveis para Hostinger

Crie o arquivo `terraform/modules/vps-base-hostinger/variables.tf`:

```hcl
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
```

## ⚙️ Configurações Específicas da Hostinger

### Planos de VPS Disponíveis

```hcl
# Planos Hostinger
vps-1 = {
  name = "VPS 1"
  cpu  = 1
  ram  = "1GB"
  disk = "20GB SSD"
  price = "€3.99/mês"
}

vps-2 = {
  name = "VPS 2"
  cpu  = 2
  ram  = "2GB"
  disk = "40GB SSD"
  price = "€7.99/mês"
}

vps-3 = {
  name = "VPS 3"
  cpu  = 3
  ram  = "4GB"
  disk = "80GB SSD"
  price = "€15.99/mês"
}

vps-4 = {
  name = "VPS 4"
  cpu  = 4
  ram  = "8GB"
  disk = "160GB SSD"
  price = "€31.99/mês"
}

vps-5 = {
  name = "VPS 5"
  cpu  = 6
  ram  = "16GB"
  disk = "320GB SSD"
  price = "€63.99/mês"
}
```

### Regiões Disponíveis

```hcl
# Regiões Hostinger
regions = {
  amsterdam   = "Amsterdam, Netherlands"
  london      = "London, UK"
  frankfurt   = "Frankfurt, Germany"
  newyork     = "New York, USA"
  losangeles  = "Los Angeles, USA"
  singapore   = "Singapore"
  tokyo       = "Tokyo, Japan"
}
```

## 🎮 Configuração por Jogo

### Sons of the Forest

```hcl
# Configuração recomendada para SotF
game_type = "sotf"
instance_size = "vps-3"  # 3 CPU, 4GB RAM
region = "amsterdam"
max_players = 8
```

### Minecraft

```hcl
# Configuração recomendada para Minecraft
game_type = "minecraft"
instance_size = "vps-2"  # 2 CPU, 2GB RAM
region = "amsterdam"
max_players = 20
```

### Valheim

```hcl
# Configuração recomendada para Valheim
game_type = "valheim"
instance_size = "vps-2"  # 2 CPU, 2GB RAM
region = "amsterdam"
max_players = 10
```

## 🔧 Troubleshooting Hostinger

### Problemas Comuns

#### VPS não cria
```bash
# Verificar credenciais
echo $TF_VAR_hostinger_api_key

# Verificar região
terraform plan -var="region=amsterdam"

# Verificar plano
terraform plan -var="instance_size=vps-1"
```

#### SSH não conecta
```bash
# Verificar chave SSH
ssh-add -l

# Testar conexão
ssh -i ~/.ssh/id_rsa root@IP_DO_SERVIDOR

# Verificar no painel Hostinger
# Vá para VPS > SSH Keys
```

#### Firewall não aplica
```bash
# Verificar regras no painel Hostinger
# Vá para VPS > Firewall

# Verificar regras locais
ufw status
```

### Logs e Monitoramento

#### Logs do Sistema
```bash
# SSH no servidor
ssh root@IP_DO_SERVIDOR

# Logs do systemd
journalctl -u GAME_TYPE-server -f

# Logs do jogo
tail -f /home/gameserver/logs/GAME_TYPE-server.log
```

#### Monitoramento de Recursos
```bash
# CPU e memória
htop

# Uso de disco
df -h

# Processos do jogo
ps aux | grep GAME_TYPE
```

## 💰 Custos e Otimização

### Estimativa de Custos

| Jogo | Plano Recomendado | Custo Mensal | Jogadores |
|------|------------------|--------------|-----------|
| Sons of the Forest | VPS 3 | €15.99 | 8 |
| Minecraft | VPS 2 | €7.99 | 20 |
| Valheim | VPS 2 | €7.99 | 10 |
| Rust | VPS 4 | €31.99 | 50 |
| ARK | VPS 4 | €31.99 | 20 |

### Dicas de Otimização

1. **Escolha a região mais próxima** dos jogadores
2. **Use o plano mínimo** para testes
3. **Monitore o uso de recursos** regularmente
4. **Configure backup automático** para saves
5. **Use CDN** para distribuição global

## 🔄 Atualizações e Manutenção

### Atualizar Servidor

```bash
# Via Ansible
cd ansible
ansible-playbook -i IP_DO_SERVIDOR, playbooks/update-game.yml --extra-vars "game_type=TIPO"
```

### Backup de Saves

```bash
# Backup automático
cd ansible
ansible-playbook -i IP_DO_SERVIDOR, playbooks/backup-game.yml --extra-vars "game_type=TIPO"
```

### Limpeza

```bash
# Remover servidor
cd terraform
terraform destroy
```

## 📊 Monitoramento Avançado

### Configurar Alertas

```bash
# Editar script de monitoramento
nano /home/gameserver/monitor.sh

# Adicionar alertas por email
if [ $CPU_USAGE -gt 90 ]; then
    echo "CPU alto: ${CPU_USAGE}%" | mail -s "ALERTA HOSTINGER" admin@exemplo.com
fi
```

### Métricas de Performance

```bash
# Script de coleta de métricas
#!/bin/bash
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
echo "RAM: $(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s", $5}')"
echo "Uptime: $(uptime -p)"
```

## 🆘 Suporte

### Recursos da Hostinger

- **Documentação**: [Hostinger API Docs](https://developers.hostinger.com/)
- **Suporte**: [Hostinger Support](https://www.hostinger.com/help)
- **Status**: [Hostinger Status](https://status.hostinger.com/)

### Recursos do Game.Servers

- **GitHub Issues**: [Link para issues]
- **Discord**: [Link para Discord]
- **Email**: [Seu email]

## 📚 Próximos Passos

1. **Configure suas credenciais** da Hostinger
2. **Teste com um servidor pequeno** (VPS 1)
3. **Monitore performance** e ajuste conforme necessário
4. **Configure backup automático** para saves
5. **Expanda para outros jogos** conforme necessário

---

**Nota**: Este guia é específico para Hostinger. Para outros provedores, consulte a documentação específica de cada um.
