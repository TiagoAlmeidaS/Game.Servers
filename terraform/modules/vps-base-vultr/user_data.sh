#!/bin/bash
# terraform/modules/vps-base-vultr/user_data.sh

# Atualizar sistema
apt-get update && apt-get upgrade -y

# Instalar dependências básicas
apt-get install -y curl wget git unzip

# Instalar SteamCMD
apt-get install -y steamcmd

# Instalar Java (para Minecraft)
apt-get install -y openjdk-17-jdk

# Instalar Ansible
apt-get install -y software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt-get install -y ansible

# Instalar Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get install -y terraform

# Configurar firewall básico
ufw --force enable
ufw allow ssh
ufw allow 25565/tcp  # Minecraft
ufw allow 8766/tcp   # Sons of the Forest
ufw allow 2456/tcp   # Valheim
ufw allow 28015/tcp  # Rust
ufw allow 7777/tcp   # ARK

# Criar usuário para jogos
useradd -m -s /bin/bash gameuser
usermod -aG sudo gameuser

# Configurar diretórios
mkdir -p /opt/games
chown -R gameuser:gameuser /opt/games

# Log de inicialização
echo "Vultr VPS configurada com sucesso!" >> /var/log/vps-setup.log
echo "Data: $(date)" >> /var/log/vps-setup.log