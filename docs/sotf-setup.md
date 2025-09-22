# Setup Completo do Sons of the Forest

Este guia cobre o provisionamento completo de um servidor Sons of the Forest usando IaC (Infrastructure as Code) com Terraform e Ansible.

## 📋 Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.5.0
- **Ansible** >= 2.15.0
- **Git** (para versionamento)
- **SSH** configurado

### Contas e Credenciais
- Conta no DigitalOcean com token de API
- Chave SSH cadastrada no DigitalOcean
- Acesso ao Steam (para download do servidor)

## 🚀 Quick Start

### 1. Configuração Inicial

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/Game.Servers.git
cd Game.Servers

# Configure as variáveis
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

### 2. Editar Configurações

Edite o arquivo `terraform/terraform.tfvars`:

```hcl
# Credenciais
do_token = "seu-token-do-digitalocean"
ssh_key_id = "seu-ssh-key-id"

# Configuração do servidor SotF
server_name = "MeuServidorSotF"
game_type = "sotf"
server_password = "minha-senha-segura"
max_players = 8

# Infraestrutura
environment = "dev"
region = "nyc3"
instance_size = "s-2vcpu-8gb"
```

### 3. Deploy do Servidor

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 4. Conectar no Jogo

Após o deploy, o Terraform exibirá o IP do servidor. Conecte no Sons of the Forest usando:
- **IP**: Mostrado no output do Terraform
- **Porta**: 8766 (padrão)
- **Senha**: A que você configurou

## 🏗️ Arquitetura do Deploy

### Terraform (Provisionamento)
1. **VPS**: Cria droplet Ubuntu 22.04 no DigitalOcean
2. **Firewall**: Configura portas 8766 (TCP/UDP) e SSH
3. **Networking**: Configura IP público e tags
4. **Ansible**: Chama playbook para configuração

### Ansible (Configuração)
1. **Dependências**: Instala SteamCMD e bibliotecas
2. **Download**: Baixa servidor SotF via SteamCMD
3. **Configuração**: Cria arquivos de config
4. **Serviço**: Configura systemd para auto-start
5. **Monitoramento**: Configura logs e monitoramento

## ⚙️ Configurações Avançadas

### Personalizar Configuração do Servidor

Edite o template `ansible/roles/sotf/templates/dedicatedserver.cfg.j2`:

```json
{
  "serverName": "{{ server_name }}",
  "serverPassword": "{{ server_password }}",
  "maxPlayers": {{ max_players }},
  "gameDifficulty": "Normal",
  "port": 8766,
  "saveInterval": 300,
  "enableVAC": true,
  "enableCheats": false,
  "enableMods": true,
  "enablePvP": true
}
```

### Configurações de Recursos

Para servidores com mais jogadores, ajuste o tamanho da instância:

```hcl
# Para 8-16 jogadores
instance_size = "s-2vcpu-8gb"

# Para 16+ jogadores
instance_size = "s-4vcpu-8gb"

# Para servidores de teste
instance_size = "s-1vcpu-2gb"
```

### Portas Customizadas

```hcl
# Usar porta customizada
game_ports = [
  { port = "8767", protocol = "tcp" },
  { port = "8767", protocol = "udp" }
]
```

## 🔧 Troubleshooting

### Problemas Comuns

#### Servidor não inicia
```bash
# SSH no servidor
ssh root@SEU_IP

# Verificar logs
journalctl -u sotf-server -f

# Verificar status
systemctl status sotf-server
```

#### Porta não acessível
```bash
# Verificar firewall
ufw status

# Verificar portas abertas
netstat -tuln | grep 8766
```

#### Problemas de conectividade
```bash
# Testar conectividade
ping 8.8.8.8

# Verificar DNS
nslookup google.com
```

### Logs e Monitoramento

#### Logs do Servidor
```bash
# Logs do systemd
journalctl -u sotf-server -f

# Logs do jogo
tail -f /home/gameserver/logs/sotf-server.log

# Logs de monitoramento
tail -f /home/gameserver/logs/monitor.log
```

#### Monitoramento de Recursos
```bash
# CPU e memória
htop

# Uso de disco
df -h

# Processos do jogo
ps aux | grep SonsOfTheForest
```

## 🔄 Atualizações

### Atualizar Servidor SotF
```bash
# SSH no servidor
ssh root@SEU_IP

# Parar serviço
systemctl stop sotf-server

# Atualizar via SteamCMD
cd /opt/gameservers/sotf
steamcmd +login anonymous +app_update 2465200 validate +quit

# Reiniciar serviço
systemctl start sotf-server
```

### Atualizar via Ansible
```bash
# Re-executar playbook
cd ansible
ansible-playbook -i IP_DO_SERVIDOR, playbooks/update-game.yml --extra-vars "game_type=sotf"
```

## 🗑️ Limpeza

### Remover Servidor
```bash
cd terraform
terraform destroy
```

### Backup Manual
```bash
# SSH no servidor
ssh root@SEU_IP

# Fazer backup dos saves
tar -czf backup-sotf-$(date +%Y%m%d).tar.gz /opt/gameservers/sotf/saves/
```

## 📊 Monitoramento Avançado

### Configurar Alertas
Edite `/home/gameserver/monitor.sh` para adicionar notificações:

```bash
# Enviar email em caso de problema
if ! systemctl is-active --quiet sotf-server; then
    echo "Servidor SotF inativo!" | mail -s "ALERTA" admin@exemplo.com
fi
```

### Métricas de Performance
```bash
# Script de coleta de métricas
#!/bin/bash
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
echo "RAM: $(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s", $5}')"
```

## 🎮 Configurações de Jogo

### Dificuldade
- **Peaceful**: Sem inimigos
- **Normal**: Dificuldade padrão
- **Hard**: Mais desafiador

### Mods Suportados
O servidor suporta mods via BepInEx. Para instalar:

1. Baixe o BepInEx para SotF
2. Extraia no diretório do servidor
3. Reinicie o serviço

### Configurações de PvP
```json
{
  "enablePvP": true,
  "enableFriendlyFire": false,
  "enableBuildingDestruction": true
}
```

## 🔐 Segurança

### Boas Práticas
- Use senhas fortes para o servidor
- Mantenha o sistema atualizado
- Configure backup automático
- Monitore logs regularmente
- Use chaves SSH em vez de senhas

### Firewall
```bash
# Verificar regras ativas
ufw status verbose

# Adicionar regra específica
ufw allow from 192.168.1.0/24 to any port 8766
```

## 📈 Escalabilidade

### Múltiplos Servidores
Para criar múltiplos servidores SotF:

```hcl
# terraform/main.tf
resource "digitalocean_droplet" "sotf_servers" {
  count  = 3
  name   = "sotf-server-${count.index + 1}"
  # ... outras configurações
}
```

### Load Balancing
Para balanceamento de carga, considere usar:
- Nginx como proxy reverso
- DNS round-robin
- Health checks automáticos

## 🆘 Suporte

### Recursos Úteis
- [Documentação oficial do SotF](https://store.steampowered.com/app/1326470/Sons_of_the_Forest/)
- [Fórum da comunidade](https://steamcommunity.com/app/1326470)
- [Wiki do jogo](https://sons-of-the-forest.fandom.com/)

### Contato
- GitHub Issues: [Link para issues]
- Discord: [Link para Discord]
- Email: [Seu email]

---

**Nota**: Este guia é específico para Sons of the Forest. Para outros jogos, consulte a documentação específica de cada um.
