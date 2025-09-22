#!/bin/bash
# Script de teste específico para Hostinger

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Teste Hostinger - Game.Servers${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_header

# Verificar se está no diretório correto
if [ ! -f "README.md" ] || [ ! -d "terraform" ]; then
    print_error "Execute este script na raiz do projeto Game.Servers"
    exit 1
fi

# Verificar credenciais
if [ -z "$HOSTINGER_TOKEN" ]; then
    print_error "HOSTINGER_TOKEN não configurado"
    print_message "Configure: export HOSTINGER_TOKEN='seu-token'"
    exit 1
fi

if [ -z "$HOSTINGER_SSH_KEY_ID" ]; then
    print_error "HOSTINGER_SSH_KEY_ID não configurado"
    print_message "Configure: export HOSTINGER_SSH_KEY_ID='seu-ssh-key-id'"
    exit 1
fi

# Teste 1: Sons of the Forest
print_message "🧪 Teste 1: Sons of the Forest"
cat > terraform/terraform.tfvars << EOF
provider = "hostinger"
hostinger_token = "$HOSTINGER_TOKEN"
ssh_key_id = "$HOSTINGER_SSH_KEY_ID"
server_name = "TesteSotF"
game_type = "sotf"
server_password = "teste123"
max_players = 8
environment = "dev"
region = "us-east"
plan_id = "vps-1"
EOF

cd terraform
terraform init
terraform plan -var="provider=hostinger" -var="game_type=sotf" -var="environment=dev"

print_warning "Deseja continuar com o deploy do Sons of the Forest? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    terraform apply -var="provider=hostinger" -var="game_type=sotf" -var="environment=dev" -auto-approve
    SOTF_IP=$(terraform output -raw server_ip)
    print_message "✅ Sons of the Forest deployado em: $SOTF_IP"
    
    # Verificar se está funcionando
    print_message "🔍 Verificando conectividade..."
    if command -v nc &> /dev/null; then
        if nc -z "$SOTF_IP" 8766; then
            print_message "✅ Porta 8766 (Sons of the Forest) aberta"
        else
            print_warning "⚠️ Porta 8766 (Sons of the Forest) fechada"
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
else
    print_message "Teste do Sons of the Forest cancelado"
fi

# Teste 2: Minecraft
print_message "🧪 Teste 2: Minecraft"
cat > terraform.tfvars << EOF
provider = "hostinger"
hostinger_token = "$HOSTINGER_TOKEN"
ssh_key_id = "$HOSTINGER_SSH_KEY_ID"
server_name = "TesteMinecraft"
game_type = "minecraft"
max_players = 20
environment = "dev"
region = "us-east"
plan_id = "vps-1"
EOF

print_warning "Deseja continuar com o deploy do Minecraft? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    terraform apply -var="provider=hostinger" -var="game_type=minecraft" -var="environment=dev" -auto-approve
    MINECRAFT_IP=$(terraform output -raw server_ip)
    print_message "✅ Minecraft deployado em: $MINECRAFT_IP"
    
    # Verificar se está funcionando
    print_message "🔍 Verificando conectividade..."
    if command -v nc &> /dev/null; then
        if nc -z "$MINECRAFT_IP" 25565; then
            print_message "✅ Porta 25565 (Minecraft) aberta"
        else
            print_warning "⚠️ Porta 25565 (Minecraft) fechada"
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
else
    print_message "Teste do Minecraft cancelado"
fi

# Teste 3: Valheim
print_message "🧪 Teste 3: Valheim"
cat > terraform.tfvars << EOF
provider = "hostinger"
hostinger_token = "$HOSTINGER_TOKEN"
ssh_key_id = "$HOSTINGER_SSH_KEY_ID"
server_name = "TesteValheim"
game_type = "valheim"
server_password = "teste123"
max_players = 10
environment = "dev"
region = "us-east"
plan_id = "vps-1"
EOF

print_warning "Deseja continuar com o deploy do Valheim? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    terraform apply -var="provider=hostinger" -var="game_type=valheim" -var="environment=dev" -auto-approve
    VALHEIM_IP=$(terraform output -raw server_ip)
    print_message "✅ Valheim deployado em: $VALHEIM_IP"
    
    # Verificar se está funcionando
    print_message "🔍 Verificando conectividade..."
    if command -v nc &> /dev/null; then
        if nc -z "$VALHEIM_IP" 2456; then
            print_message "✅ Porta 2456 (Valheim) aberta"
        else
            print_warning "⚠️ Porta 2456 (Valheim) fechada"
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
else
    print_message "Teste do Valheim cancelado"
fi

# Resumo dos testes
print_message "🎉 Testes concluídos!"
echo ""
print_header
echo "Servidores deployados:"
if [ ! -z "$SOTF_IP" ]; then
    echo "Sons of the Forest: $SOTF_IP:8766"
fi
if [ ! -z "$MINECRAFT_IP" ]; then
    echo "Minecraft: $MINECRAFT_IP:25565"
fi
if [ ! -z "$VALHEIM_IP" ]; then
    echo "Valheim: $VALHEIM_IP:2456"
fi
echo ""

# Limpeza (opcional)
print_warning "Deseja destruir os servidores de teste? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    print_message "Destruindo servidores de teste..."
    terraform destroy -auto-approve
    print_message "Servidores destruídos!"
fi

cd ..
print_message "Teste do Hostinger concluído! 🚀"
