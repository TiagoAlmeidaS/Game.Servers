#!/bin/bash
# User data script para configuração inicial da instância EC2

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

# Configurar CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Configurar CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/gameserver/logs/*.log",
            "log_group_name": "/aws/ec2/${game_type}",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/aws/ec2/${game_type}-system",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "GameServers/${game_type}",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Iniciar CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

# Log da inicialização
echo "EC2 instance inicializada para jogo: ${game_type}" >> /var/log/gameserver-init.log
