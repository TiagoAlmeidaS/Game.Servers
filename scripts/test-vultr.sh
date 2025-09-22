#!/bin/bash
# scripts/test-vultr.sh

set -e

echo "🧪 Iniciando teste do Game.Servers com Vultr..."

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
    exit 1
}

# Verificar se está no diretório correto
if [ ! -f "README.md" ] || [ ! -d "terraform" ]; then
    print_error "Execute este script na raiz do projeto Game.Servers"
fi

# Verificar credenciais
if [ -z "$VULTR_API_KEY" ]; then
    print_error "VULTR_API_KEY não configurado. Por favor, defina a variável de ambiente."
fi

if [ -z "$VULTR_SSH_KEY_ID" ]; then
    print_error "VULTR_SSH_KEY_ID não configurado. Por favor, defina a variável de ambiente."
fi

# Executar setup
print_message "Configurando Vultr..."
./scripts/setup-vultr.sh

# Deploy do servidor
print_message "Deployando servidor Minecraft..."
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

SERVER_IP=$(terraform output -raw server_ip)
print_message "Servidor deployado em: $SERVER_IP"
cd ..

# Aguardar servidor ficar disponível
print_message "Aguardando servidor ficar disponível..."
sleep 60

# Verificar conectividade
print_message "Verificando conectividade..."
if ping -c 1 "$SERVER_IP" > /dev/null 2>&1; then
    print_message "✅ Servidor respondendo ao ping"
else
    print_warning "⚠️ Servidor não responde ao ping ainda"
fi

# Resumo
print_message "🎉 Teste concluído!"
echo ""
echo "Servidor Minecraft: $SERVER_IP:25565"
echo "Custo: R$ 17,50/mês"
echo "Região: São Paulo (Brasil)"
echo ""
echo "Para conectar no Minecraft:"
echo "IP: $SERVER_IP"
echo "Porta: 25565"
echo ""
echo "Para destruir o servidor:"
echo "cd terraform && terraform destroy"
