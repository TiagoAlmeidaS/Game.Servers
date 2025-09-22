#!/bin/bash
# User data script para configuração inicial da instância Linode

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

# Configurar Longview (monitoramento Linode)
wget -O - https://lv.linode.com/ | bash

# Configurar Longview para monitoramento de jogos
cat > /etc/linode/longview.d/gameserver.conf << EOF
[gameserver]
type = log
path = /home/gameserver/logs/*.log
format = none
EOF

# Log da inicialização
echo "Linode instance inicializada para jogo: ${game_type}" >> /var/log/gameserver-init.log
