# 🚀 Configuração do Vultr para Game.Servers

Este guia mostra como configurar e usar o Vultr como provedor de cloud para o Game.Servers.

## 📋 Pré-requisitos

1. **Conta no Vultr**: [Criar conta gratuita](https://www.vultr.com/)
2. **API Key**: Obter em [Vultr API Settings](https://my.vultr.com/settings/#settingsapi)
3. **Chave SSH**: Criar em [Vultr SSH Keys](https://my.vultr.com/settings/#settingsssh)
4. **Terraform**: Instalar [Terraform](https://terraform.io/downloads)
5. **Ansible**: Instalar com `pip install ansible`

## 🔑 Configuração das Credenciais

### 1. Obter API Key do Vultr

1. Acesse [Vultr API Settings](https://my.vultr.com/settings/#settingsapi)
2. Clique em "Enable API"
3. Copie sua API Key

### 2. Criar Chave SSH

1. Acesse [Vultr SSH Keys](https://my.vultr.com/settings/#settingsssh)
2. Clique em "Add SSH Key"
3. Cole sua chave SSH pública
4. Anote o ID da chave SSH

### 3. Configurar Variáveis de Ambiente

```bash
# Windows (PowerShell)
$env:VULTR_API_KEY="sua-api-key-aqui"
$env:VULTR_SSH_KEY_ID="seu-ssh-key-id-aqui"

# Linux/macOS
export VULTR_API_KEY="sua-api-key-aqui"
export VULTR_SSH_KEY_ID="seu-ssh-key-id-aqui"
```

## 🎮 Jogos Suportados

| Jogo | Porta | Custo/mês | Recursos Recomendados |
|------|-------|-----------|----------------------|
| **Minecraft** | 25565 | R$ 17,50 | vc2-1c-1gb |
| **Sons of the Forest** | 8766 | R$ 35,00 | vc2-2c-2gb |
| **Valheim** | 2456 | R$ 35,00 | vc2-2c-2gb |
| **Rust** | 28015 | R$ 70,00 | vc2-4c-8gb |
| **ARK** | 7777 | R$ 70,00 | vc2-4c-8gb |

## 💰 Planos Vultr Disponíveis

| Plano | vCPU | RAM | Disco | Custo/mês | Ideal para |
|-------|------|-----|-------|-----------|------------|
| **vc2-1c-1gb** | 1 | 1GB | 25GB | **R$ 17,50** | Minecraft |
| **vc2-2c-2gb** | 2 | 2GB | 50GB | **R$ 35,00** | Valheim, SotF |
| **vc2-4c-8gb** | 4 | 8GB | 100GB | **R$ 70,00** | Rust, ARK |
| **vc2-8c-16gb** | 8 | 16GB | 200GB | **R$ 140,00** | Servidores grandes |

## 🌍 Regiões Disponíveis

| Região | Código | Localização |
|--------|--------|-------------|
| **São Paulo** | sao-paulo | Brasil |
| **New York** | nyc3 | EUA |
| **Los Angeles** | lax | EUA |
| **Amsterdam** | ams | Holanda |
| **Frankfurt** | fra | Alemanha |
| **London** | lhr | Reino Unido |
| **Singapore** | sgp | Singapura |
| **Tokyo** | nrt | Japão |

## 🚀 Deploy Rápido

### 1. Setup Automático

```bash
# Executar setup do Vultr
./scripts/setup-vultr.sh
```

### 2. Deploy do Servidor

```bash
# Deploy com Vultr
./scripts/deploy-universal.sh vultr minecraft dev

# Deploy de outros jogos
./scripts/deploy-universal.sh vultr sotf dev
./scripts/deploy-universal.sh vultr valheim dev
./scripts/deploy-universal.sh vultr rust dev
./scripts/deploy-universal.sh vultr ark dev
```

### 3. Teste Completo

```bash
# Teste completo do Vultr
./scripts/test-vultr.sh
```

## ⚙️ Configuração Manual

### 1. Arquivo de Configuração

Crie o arquivo `terraform/terraform.tfvars`:

```hcl
# Configuração para Vultr
provider = "vultr"
vultr_api_key = "sua-api-key-aqui"
ssh_key_id = "seu-ssh-key-id-aqui"
region = "sao-paulo"
plan_id = "vc2-1c-1gb"
game_type = "minecraft"
server_name = "MeuServidorMinecraft"
max_players = 10
environment = "dev"
```

### 2. Deploy com Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## 🔧 Configurações Avançadas

### 1. Configuração de Firewall

O Vultr automaticamente configura as portas necessárias:

- **Minecraft**: 25565 (TCP/UDP)
- **Sons of the Forest**: 8766 (TCP/UDP)
- **Valheim**: 2456 (TCP/UDP)
- **Rust**: 28015 (TCP/UDP)
- **ARK**: 7777 (TCP/UDP)

### 2. Configuração de Backup

```hcl
# Habilitar backup automático
enable_backup = true
backup_interval = 24  # horas
backup_retention = 7  # dias
```

### 3. Configuração de Monitoramento

```hcl
# Habilitar monitoramento
enable_monitoring = true
alert_email = "seu-email@exemplo.com"
```

## 🎯 Exemplos de Uso

### Minecraft Server

```bash
# Deploy servidor Minecraft básico
./scripts/deploy-universal.sh vultr minecraft dev

# Deploy servidor Minecraft com configurações específicas
terraform apply -var="minecraft_difficulty=hard" -var="minecraft_gamemode=survival"
```

### Sons of the Forest Server

```bash
# Deploy servidor SotF
./scripts/deploy-universal.sh vultr sotf dev

# Deploy com PvP habilitado
terraform apply -var="sotf_enable_pvp=true"
```

### Valheim Server

```bash
# Deploy servidor Valheim
./scripts/deploy-universal.sh vultr valheim dev

# Deploy com senha específica
terraform apply -var="valheim_password=minha-senha-segura"
```

## 🔍 Troubleshooting

### Problema: API Key inválida

```bash
# Verificar API Key
curl -H "API-Key: $VULTR_API_KEY" https://api.vultr.com/v1/account/info
```

### Problema: Chave SSH não encontrada

```bash
# Listar chaves SSH
curl -H "API-Key: $VULTR_API_KEY" https://api.vultr.com/v1/sshkey/list
```

### Problema: Servidor não responde

```bash
# Verificar status da instância
curl -H "API-Key: $VULTR_API_KEY" https://api.vultr.com/v1/server/list
```

## 📊 Monitoramento

### 1. Status do Servidor

```bash
# Verificar status via API
curl -H "API-Key: $VULTR_API_KEY" https://api.vultr.com/v1/server/list
```

### 2. Logs do Servidor

```bash
# Conectar via SSH
ssh root@$(terraform output -raw server_ip)

# Ver logs do jogo
tail -f /opt/games/logs/server.log
```

### 3. Métricas de Performance

```bash
# Ver uso de CPU e RAM
htop

# Ver uso de disco
df -h
```

## 🛡️ Segurança

### 1. Firewall

O Vultr automaticamente configura o firewall com as portas necessárias.

### 2. SSH

```bash
# Desabilitar login por senha
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
systemctl restart sshd
```

### 3. Atualizações

```bash
# Atualizar sistema
apt update && apt upgrade -y

# Atualizar dependências do jogo
cd /opt/games && ./update.sh
```

## 💡 Dicas de Otimização

### 1. Performance

- Use SSD para melhor performance
- Configure swap se necessário
- Monitore uso de recursos

### 2. Custo

- Use o plano menor possível para seu jogo
- Configure backup automático
- Monitore uso de recursos

### 3. Backup

```bash
# Backup manual
tar -czf backup-$(date +%Y%m%d).tar.gz /opt/games
```

## 🆘 Suporte

- **Documentação Vultr**: [docs.vultr.com](https://docs.vultr.com/)
- **API Reference**: [vultr.com/api](https://www.vultr.com/api/)
- **Status Page**: [status.vultr.com](https://status.vultr.com/)
- **Support**: [my.vultr.com/support](https://my.vultr.com/support)

## 🎉 Próximos Passos

1. **Deploy seu primeiro servidor**
2. **Configure backup automático**
3. **Configure monitoramento**
4. **Convide seus amigos**
5. **Divirta-se!** 🎮

---

**Custo total: A partir de R$ 17,50/mês** 💰
**Tempo de setup: ~5 minutos** ⏱️
**Suporte: 24/7** 🆘
