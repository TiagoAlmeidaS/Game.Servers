#!/bin/bash
# User data script para configuração inicial da VM Azure

set -e

# Atualizar sistema
apt-get update
apt-get upgrade -y

# Instalar dependências básicas
apt-get install -y \
    curl \
    wget \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Instalar SteamCMD
add-apt-repository multiverse
dpkg --add-architecture i386
apt-get update
apt-get install -y steamcmd

# Criar usuário para jogos (não root)
useradd -m -s /bin/bash gameserver
usermod -aG sudo gameserver

# Criar diretórios base
mkdir -p /opt/gameservers
mkdir -p /opt/gameservers/${game_type}
chown -R gameserver:gameserver /opt/gameservers

# Instalar dependências específicas por jogo
case "${game_type}" in
    "minecraft")
        # Java para Minecraft
        apt-get install -y openjdk-17-jdk
        ;;
    "sotf"|"valheim"|"rust"|"ark")
        # Dependências para jogos Steam
        apt-get install -y lib32gcc-s1 lib32stdc++6
        ;;
esac

# Configurar systemd para auto-start
systemctl enable systemd-resolved
systemctl start systemd-resolved

# Configurar firewall local
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 22

# Configurar Azure Monitor agent (se habilitado)
if [ -f "/opt/microsoft/omsagent/bin/omsadmin.sh" ]; then
    # Configurar logs customizados
    cat > /etc/opt/microsoft/omsagent/conf/omsagent.d/gameserver.conf << EOF
<source>
  @type tail
  path /home/gameserver/logs/*.log
  pos_file /var/log/omsagent/gameserver.log.pos
  tag gameserver.*
  format none
</source>

<match gameserver.**>
  @type out_oms
  log_level info
  num_threads 5
  buffer_chunk_limit 5m
  buffer_type file
  buffer_path /var/opt/microsoft/omsagent/state/out_oms_gameserver*
  buffer_queue_limit 10
  flush_interval 20s
  retry_limit 10
  retry_wait 30s
</match>
EOF

    # Reiniciar omsagent
    systemctl restart omsagent
fi

# Log da inicialização
echo "Azure VM inicializada para jogo: ${game_type}" >> /var/log/gameserver-init.log
