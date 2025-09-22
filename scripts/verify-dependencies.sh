#!/bin/bash
# Script de verificação de dependências do Game.Servers

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
    echo -e "${BLUE}  Verificação de Dependências${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_header

# Verificar se está no diretório correto
if [ ! -f "README.md" ] || [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
    print_error "Execute este script na raiz do projeto Game.Servers"
    exit 1
fi

# Verificar Terraform
print_message "🔍 Verificando Terraform..."
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform --version | head -n1 | cut -d' ' -f2)
    print_message "✅ Terraform instalado: $TERRAFORM_VERSION"
    
    # Verificar versão mínima
    MAJOR=$(echo "$TERRAFORM_VERSION" | cut -d'.' -f1)
    MINOR=$(echo "$TERRAFORM_VERSION" | cut -d'.' -f2)
    
    if [[ $MAJOR -gt 1 ]] || [[ $MAJOR -eq 1 && $MINOR -ge 5 ]]; then
        print_message "✅ Versão do Terraform compatível"
    else
        print_error "❌ Terraform versão $TERRAFORM_VERSION não é compatível (mínimo 1.5.0)"
        exit 1
    fi
else
    print_error "❌ Terraform não encontrado"
    print_message "Instale o Terraform: https://developer.hashicorp.com/terraform/downloads"
    exit 1
fi

# Verificar Ansible
print_message "🔍 Verificando Ansible..."
if command -v ansible &> /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2)
    print_message "✅ Ansible instalado: $ANSIBLE_VERSION"
    
    # Verificar versão mínima
    MAJOR=$(echo "$ANSIBLE_VERSION" | cut -d'.' -f1)
    MINOR=$(echo "$ANSIBLE_VERSION" | cut -d'.' -f2)
    
    if [[ $MAJOR -gt 2 ]] || [[ $MAJOR -eq 2 && $MINOR -ge 15 ]]; then
        print_message "✅ Versão do Ansible compatível"
    else
        print_error "❌ Ansible versão $ANSIBLE_VERSION não é compatível (mínimo 2.15.0)"
        exit 1
    fi
else
    print_error "❌ Ansible não encontrado"
    print_message "Instale o Ansible: https://docs.ansible.com/ansible/latest/installation_guide/"
    exit 1
fi

# Verificar Git
print_message "🔍 Verificando Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_message "✅ Git instalado: $GIT_VERSION"
else
    print_error "❌ Git não encontrado"
    print_message "Instale o Git: https://git-scm.com/downloads"
    exit 1
fi

# Verificar jq (para parsing JSON)
print_message "🔍 Verificando jq..."
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version | cut -d'-' -f2)
    print_message "✅ jq instalado: $JQ_VERSION"
else
    print_warning "⚠️ jq não encontrado (recomendado para parsing JSON)"
    print_message "Instale o jq: https://stedolan.github.io/jq/download/"
fi

# Verificar curl
print_message "🔍 Verificando curl..."
if command -v curl &> /dev/null; then
    CURL_VERSION=$(curl --version | head -n1 | cut -d' ' -f2)
    print_message "✅ curl instalado: $CURL_VERSION"
else
    print_error "❌ curl não encontrado"
    print_message "Instale o curl: https://curl.se/download.html"
    exit 1
fi

# Verificar netcat (nc)
print_message "🔍 Verificando netcat..."
if command -v nc &> /dev/null; then
    print_message "✅ netcat instalado"
else
    print_warning "⚠️ netcat não encontrado (recomendado para testes de conectividade)"
    print_message "Instale o netcat: apt-get install netcat-openbsd (Ubuntu/Debian)"
fi

# Verificar SSH
print_message "🔍 Verificando SSH..."
if command -v ssh &> /dev/null; then
    SSH_VERSION=$(ssh -V 2>&1 | cut -d' ' -f1 | cut -d'_' -f2)
    print_message "✅ SSH instalado: $SSH_VERSION"
else
    print_error "❌ SSH não encontrado"
    print_message "Instale o SSH: apt-get install openssh-client (Ubuntu/Debian)"
    exit 1
fi

# Verificar credenciais do provedor (se configuradas)
print_message "🔍 Verificando credenciais do provedor..."

if [ -n "$HOSTINGER_TOKEN" ]; then
    print_message "✅ HOSTINGER_TOKEN configurado"
else
    print_warning "⚠️ HOSTINGER_TOKEN não configurado (necessário para Hostinger)"
fi

if [ -n "$HOSTINGER_SSH_KEY_ID" ]; then
    print_message "✅ HOSTINGER_SSH_KEY_ID configurado"
else
    print_warning "⚠️ HOSTINGER_SSH_KEY_ID não configurado (necessário para Hostinger)"
fi

if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    print_message "✅ AWS_ACCESS_KEY_ID configurado"
else
    print_warning "⚠️ AWS_ACCESS_KEY_ID não configurado (necessário para AWS)"
fi

if [ -n "$AZURE_CLIENT_ID" ]; then
    print_message "✅ AZURE_CLIENT_ID configurado"
else
    print_warning "⚠️ AZURE_CLIENT_ID não configurado (necessário para Azure)"
fi

# Verificar arquivos do projeto
print_message "🔍 Verificando arquivos do projeto..."

if [ -f "terraform/main.tf" ]; then
    print_message "✅ terraform/main.tf encontrado"
else
    print_error "❌ terraform/main.tf não encontrado"
    exit 1
fi

if [ -f "ansible/roles/common/tasks/main.yml" ]; then
    print_message "✅ ansible/roles/common/tasks/main.yml encontrado"
else
    print_error "❌ ansible/roles/common/tasks/main.yml não encontrado"
    exit 1
fi

if [ -d "terraform/modules" ]; then
    print_message "✅ terraform/modules/ encontrado"
else
    print_error "❌ terraform/modules/ não encontrado"
    exit 1
fi

print_message "🎉 Todas as dependências verificadas com sucesso!"
print_message "O projeto Game.Servers está pronto para uso! 🚀"
