#!/bin/bash
# scripts/setup-vultr.sh

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_message "🚀 Configurando Game.Servers para Vultr..."

# Verificar se VULTR_API_KEY está configurada
if [ -z "$VULTR_API_KEY" ]; then
    print_error "VULTR_API_KEY não configurada"
    echo "Configure com: export VULTR_API_KEY=seu-token"
    echo "Obtenha seu token em: https://my.vultr.com/settings/#settingsapi"
    exit 1
fi

# Verificar se VULTR_SSH_KEY_ID está configurada
if [ -z "$VULTR_SSH_KEY_ID" ]; then
    print_error "VULTR_SSH_KEY_ID não configurada"
    echo "Configure com: export VULTR_SSH_KEY_ID=seu-ssh-key-id"
    echo "Crie uma chave SSH em: https://my.vultr.com/settings/#settingsssh"
    exit 1
fi

# Criar diretório terraform se não existir
mkdir -p terraform

# Copiar arquivo de variáveis
if [ ! -f "terraform/terraform.tfvars.vultr.example" ]; then
    print_message "Criando arquivo de variáveis para Vultr..."
    cat > terraform/terraform.tfvars.vultr.example << EOF
# Configurações para Vultr
provider = "vultr"
vultr_api_key = "seu-token-aqui"
ssh_key_id = "seu-ssh-key-id"
region = "sao-paulo"  # Região do Brasil
plan_id = "vc2-1c-1gb"  # Plano mais barato (R$ 17,50/mês)
game_type = "minecraft"
server_name = "MeuServidorMinecraft"
max_players = 10
environment = "dev"
EOF
fi

# Configurar variáveis
print_message "Configurando variáveis do Vultr..."
cat > terraform/terraform.tfvars << EOF
provider = "vultr"
vultr_api_key = "$VULTR_API_KEY"
ssh_key_id = "$VULTR_SSH_KEY_ID"
region = "sao-paulo"
plan_id = "vc2-1c-1gb"
game_type = "minecraft"
server_name = "MeuServidorMinecraft"
max_players = 10
environment = "dev"
EOF

print_message "✅ Configuração do Vultr concluída!"
print_message "💰 Custo estimado: R$ 17,50/mês (VPS Básico)"
print_message "🌍 Região: São Paulo (Brasil)"
print_message "🎮 Jogo: Minecraft"
print_message ""
print_message "Próximos passos:"
print_message "1. cd terraform"
print_message "2. terraform init"
print_message "3. terraform plan"
print_message "4. terraform apply"
