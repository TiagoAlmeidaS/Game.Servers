# Setup do Minecraft

Este guia cobre o provisionamento completo de um servidor Minecraft usando o Game.Servers.

## 📋 Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.5.0
- **Ansible** >= 2.15.0
- **Git** (para versionamento)
- **SSH** configurado

### Contas e Credenciais
- Conta no DigitalOcean com token de API
- Chave SSH cadastrada no DigitalOcean

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

# Configuração do servidor Minecraft
server_name = "MeuServidorMinecraft"
game_type = "minecraft"
max_players = 20

# Infraestrutura
environment = "dev"
region = "nyc3"
instance_size = "s-2vcpu-4gb"  # 4GB RAM é suficiente para Minecraft
```

### 3. Deploy do Servidor

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 4. Conectar no Jogo

Após o deploy, o Terraform exibirá o IP do servidor. Conecte no Minecraft usando:
- **IP**: Mostrado no output do Terraform
- **Porta**: 25565 (padrão)
- **Versão**: Java Edition (qualquer versão compatível)

## ⚙️ Configurações Avançadas

### Personalizar Configuração do Servidor

Edite o template `ansible/roles/minecraft/templates/server.properties.j2`:

```properties
# Configurações básicas
server-name={{ server_name }}
motd={{ server_name }} - Game.Servers
server-port=25565
max-players={{ max_players | default(20) }}
difficulty={{ minecraft_difficulty | default('normal') }}
gamemode={{ minecraft_gamemode | default('survival') }}
```

### Configurações de Recursos

Para servidores com mais jogadores, ajuste o tamanho da instância:

```hcl
# Para 20-50 jogadores
instance_size = "s-2vcpu-4gb"

# Para 50+ jogadores
instance_size = "s-4vcpu-8gb"

# Para servidores de teste
instance_size = "s-1vcpu-2gb"
```

### Configurações de Java

Ajuste as opções de Java no arquivo `ansible/roles/minecraft/defaults/main.yml`:

```yaml
minecraft_java_opts: "-Xmx4G -Xms2G -XX:+UseG1GC"
minecraft_memory_limit: "6G"
```

## 🎮 Configurações de Jogo

### Dificuldade
- **peaceful**: Sem monstros
- **easy**: Fácil
- **normal**: Normal (padrão)
- **hard**: Difícil

### Modo de Jogo
- **survival**: Sobrevivência (padrão)
- **creative**: Criativo
- **adventure**: Aventura
- **spectator**: Espectador

### Tipo de Mundo
- **minecraft:normal**: Mundo normal
- **minecraft:flat**: Mundo plano
- **minecraft:large_biomes**: Biomas grandes
- **minecraft:amplified**: Amplificado

### Configurações de Performance
```properties
# Distância de renderização
view-distance=10

# Distância de simulação
simulation-distance=10

# Tempo máximo de tick
max-tick-time=60000
```

## 🔧 Troubleshooting

### Problemas Comuns

#### Servidor não inicia
```bash
# SSH no servidor
ssh root@SEU_IP

# Verificar logs
journalctl -u minecraft-server -f

# Verificar status
systemctl status minecraft-server
```

#### Problemas de memória
```bash
# Verificar uso de memória
free -h

# Verificar logs do Java
journalctl -u minecraft-server | grep -i "outofmemory"
```

#### Porta não acessível
```bash
# Verificar firewall
ufw status

# Verificar portas abertas
netstat -tuln | grep 25565
```

### Logs e Monitoramento

#### Logs do Servidor
```bash
# Logs do systemd
journalctl -u minecraft-server -f

# Logs do jogo
tail -f /home/gameserver/logs/minecraft-server-*.log

# Logs de monitoramento
tail -f /home/gameserver/logs/monitor.log
```

#### Monitoramento de Recursos
```bash
# CPU e memória
htop

# Uso de disco
df -h

# Processos do Java
ps aux | grep java
```

## 🔄 Atualizações

### Atualizar Servidor Minecraft
```bash
# SSH no servidor
ssh root@SEU_IP

# Parar serviço
systemctl stop minecraft-server

# Fazer backup do mundo
cp -r /opt/gameservers/minecraft/world /home/gameserver/backups/world-$(date +%Y%m%d)

# Baixar nova versão
cd /opt/gameservers/minecraft
wget https://launcher.mojang.com/v1/objects/NOVA_VERSION/server.jar

# Reiniciar serviço
systemctl start minecraft-server
```

### Atualizar via Ansible
```bash
# Re-executar playbook
cd ansible
ansible-playbook -i IP_DO_SERVIDOR, playbooks/update-game.yml --extra-vars "game_type=minecraft"
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

# Fazer backup do mundo
tar -czf backup-minecraft-$(date +%Y%m%d).tar.gz /opt/gameservers/minecraft/world/
```

## 📊 Monitoramento Avançado

### Configurar Alertas
Edite `/home/gameserver/monitor.sh` para adicionar notificações:

```bash
# Verificar uso de memória
MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
if (( $(echo "$MEM_USAGE > 90" | bc -l) )); then
    echo "Uso de RAM alto: ${MEM_USAGE}%" | mail -s "ALERTA MINECRAFT" admin@exemplo.com
fi
```

### Métricas de Performance
```bash
# Script de coleta de métricas
#!/bin/bash
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
echo "RAM: $(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s", $5}')"
echo "Players: $(grep -c "joined the game" /home/gameserver/logs/minecraft-server-*.log | tail -1)"
```

## 🎮 Plugins e Mods

### Instalar Plugins (Spigot/Paper)
```bash
# Baixar Spigot
cd /opt/gameservers/minecraft
wget https://download.getbukkit.org/spigot/spigot-1.20.1.jar

# Instalar plugin
mkdir -p plugins
wget -O plugins/plugin.jar URL_DO_PLUGIN
```

### Instalar Mods (Fabric/Forge)
```bash
# Baixar Fabric
cd /opt/gameservers/minecraft
wget https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.2/fabric-installer-0.11.2.jar
java -jar fabric-installer-0.11.2.jar server
```

## 🔐 Segurança

### Boas Práticas
- Use whitelist para controlar acesso
- Mantenha o servidor atualizado
- Configure backup automático
- Monitore logs regularmente
- Use senhas fortes para ops

### Configurações de Segurança
```properties
# Ativar whitelist
white-list=true
enforce-whitelist=true

# Modo online (verificação de contas)
online-mode=true

# Proteção do spawn
spawn-protection=16
```

## 📈 Escalabilidade

### Múltiplos Servidores
Para criar múltiplos servidores Minecraft:

```hcl
# terraform/main.tf
resource "digitalocean_droplet" "minecraft_servers" {
  count  = 3
  name   = "minecraft-server-${count.index + 1}"
  # ... outras configurações
}
```

### Load Balancing
Para balanceamento de carga, considere usar:
- BungeeCord para proxy
- DNS round-robin
- Health checks automáticos

## 🆘 Suporte

### Recursos Úteis
- [Documentação oficial do Minecraft](https://minecraft.fandom.com/wiki/Server.properties)
- [Spigot Documentation](https://www.spigotmc.org/wiki/)
- [Fabric Documentation](https://fabricmc.net/wiki/)

### Contato
- GitHub Issues: [Link para issues]
- Discord: [Link para Discord]
- Email: [Seu email]

---

**Nota**: Este guia é específico para Minecraft. Para outros jogos, consulte a documentação específica de cada um.
