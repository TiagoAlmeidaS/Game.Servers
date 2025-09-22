#!/bin/bash
# Script de verificação de credenciais do provedor

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
    echo -e "${BLUE}  Verificação de Credenciais${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar parâmetros
if [ $# -lt 1 ]; then
    print_error "Uso: $0 <provedor>"
    echo ""
    echo "Provedores suportados:"
    echo "  - hostinger"
    echo "  - aws"
    echo "  - azure"
    echo "  - digitalocean"
    echo "  - linode"
    echo "  - vultr"
    exit 1
fi

PROVIDER=$1

print_header
print_message "🔍 Verificando credenciais do provedor: $PROVIDER"

case $PROVIDER in
  "hostinger")
    print_message "🔍 Verificando credenciais da Hostinger..."
    
    if [ -z "$HOSTINGER_TOKEN" ]; then
        print_error "❌ HOSTINGER_TOKEN não configurado"
        print_message "Configure: export HOSTINGER_TOKEN='seu-token'"
        exit 1
    fi
    
    # Testar API da Hostinger
    response=$(curl -s -H "Authorization: Bearer $HOSTINGER_TOKEN" https://api.hostinger.com/v1/user 2>/dev/null || echo "error")
    
    if echo "$response" | grep -q "error" || [ "$response" = "error" ]; then
        print_error "❌ Token da Hostinger inválido ou API indisponível"
        print_message "Verifique se o token está correto e se a API está funcionando"
        exit 1
    else
        print_message "✅ Credenciais da Hostinger válidas"
        
        # Verificar SSH Key ID
        if [ -z "$HOSTINGER_SSH_KEY_ID" ]; then
            print_warning "⚠️ HOSTINGER_SSH_KEY_ID não configurado"
            print_message "Configure: export HOSTINGER_SSH_KEY_ID='seu-ssh-key-id'"
        else
            print_message "✅ HOSTINGER_SSH_KEY_ID configurado"
        fi
    fi
    ;;
    
  "aws")
    print_message "🔍 Verificando credenciais da AWS..."
    
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        print_error "❌ AWS_ACCESS_KEY_ID não configurado"
        print_message "Configure: export AWS_ACCESS_KEY_ID='sua-access-key'"
        exit 1
    fi
    
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        print_error "❌ AWS_SECRET_ACCESS_KEY não configurado"
        print_message "Configure: export AWS_SECRET_ACCESS_KEY='sua-secret-key'"
        exit 1
    fi
    
    # Testar AWS CLI
    if command -v aws &> /dev/null; then
        if aws sts get-caller-identity > /dev/null 2>&1; then
            print_message "✅ Credenciais da AWS válidas"
        else
            print_error "❌ Credenciais da AWS inválidas"
            exit 1
        fi
    else
        print_warning "⚠️ AWS CLI não instalado, não é possível verificar credenciais"
        print_message "Instale: https://aws.amazon.com/cli/"
    fi
    ;;
    
  "azure")
    print_message "🔍 Verificando credenciais da Azure..."
    
    if [ -z "$AZURE_CLIENT_ID" ]; then
        print_error "❌ AZURE_CLIENT_ID não configurado"
        print_message "Configure: export AZURE_CLIENT_ID='seu-client-id'"
        exit 1
    fi
    
    if [ -z "$AZURE_CLIENT_SECRET" ]; then
        print_error "❌ AZURE_CLIENT_SECRET não configurado"
        print_message "Configure: export AZURE_CLIENT_SECRET='seu-client-secret'"
        exit 1
    fi
    
    if [ -z "$AZURE_SUBSCRIPTION_ID" ]; then
        print_error "❌ AZURE_SUBSCRIPTION_ID não configurado"
        print_message "Configure: export AZURE_SUBSCRIPTION_ID='seu-subscription-id'"
        exit 1
    fi
    
    if [ -z "$AZURE_TENANT_ID" ]; then
        print_error "❌ AZURE_TENANT_ID não configurado"
        print_message "Configure: export AZURE_TENANT_ID='seu-tenant-id'"
        exit 1
    fi
    
    # Testar Azure CLI
    if command -v az &> /dev/null; then
        if az account show > /dev/null 2>&1; then
            print_message "✅ Credenciais da Azure válidas"
        else
            print_warning "⚠️ Azure CLI não autenticado"
            print_message "Execute: az login"
        fi
    else
        print_warning "⚠️ Azure CLI não instalado, não é possível verificar credenciais"
        print_message "Instale: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    fi
    ;;
    
  "digitalocean")
    print_message "🔍 Verificando credenciais da DigitalOcean..."
    
    if [ -z "$DO_TOKEN" ]; then
        print_error "❌ DO_TOKEN não configurado"
        print_message "Configure: export DO_TOKEN='seu-token'"
        exit 1
    fi
    
    # Testar API da DigitalOcean
    response=$(curl -s -H "Authorization: Bearer $DO_TOKEN" https://api.digitalocean.com/v2/account 2>/dev/null || echo "error")
    
    if echo "$response" | grep -q "error" || [ "$response" = "error" ]; then
        print_error "❌ Token da DigitalOcean inválido ou API indisponível"
        exit 1
    else
        print_message "✅ Credenciais da DigitalOcean válidas"
    fi
    ;;
    
  "linode")
    print_message "🔍 Verificando credenciais da Linode..."
    
    if [ -z "$LINODE_TOKEN" ]; then
        print_error "❌ LINODE_TOKEN não configurado"
        print_message "Configure: export LINODE_TOKEN='seu-token'"
        exit 1
    fi
    
    # Testar API da Linode
    response=$(curl -s -H "Authorization: Bearer $LINODE_TOKEN" https://api.linode.com/v4/profile 2>/dev/null || echo "error")
    
    if echo "$response" | grep -q "error" || [ "$response" = "error" ]; then
        print_error "❌ Token da Linode inválido ou API indisponível"
        exit 1
    else
        print_message "✅ Credenciais da Linode válidas"
    fi
    ;;
    
  "vultr")
    print_message "🔍 Verificando credenciais da Vultr..."
    
    if [ -z "$VULTR_API_KEY" ]; then
        print_error "❌ VULTR_API_KEY não configurado"
        print_message "Configure: export VULTR_API_KEY='sua-api-key'"
        exit 1
    fi
    
    # Testar API da Vultr
    response=$(curl -s -H "API-Key: $VULTR_API_KEY" https://api.vultr.com/v2/account 2>/dev/null || echo "error")
    
    if echo "$response" | grep -q "error" || [ "$response" = "error" ]; then
        print_error "❌ API Key da Vultr inválida ou API indisponível"
        exit 1
    else
        print_message "✅ Credenciais da Vultr válidas"
    fi
    ;;
    
  *)
    print_error "❌ Provedor '$PROVIDER' não suportado"
    print_message "Provedores suportados: hostinger, aws, azure, digitalocean, linode, vultr"
    exit 1
    ;;
esac

print_message "🎉 Credenciais do provedor $PROVIDER verificadas com sucesso!"
