#!/bin/bash
# Script universal de deploy para qualquer provedor

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
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
    echo -e "${BLUE}  Game.Servers - Deploy Universal${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar parâmetros
if [ $# -lt 2 ]; then
    print_error "Uso: $0 <provedor> <jogo> [ambiente]"
    echo ""
    echo "Provedores suportados:"
    echo "  - digitalocean"
    echo "  - hostinger"
    echo "  - aws"
    echo "  - azure"
    echo "  - linode"
    echo "  - vultr"
    echo ""
    echo "Jogos suportados:"
    echo "  - sotf (Sons of the Forest)"
    echo "  - minecraft"
    echo "  - valheim"
    echo "  - rust"
    echo "  - ark"
    echo ""
    echo "Exemplo: $0 digitalocean sotf dev"
    exit 1
fi

PROVIDER=$1
GAME_TYPE=$2
ENVIRONMENT=${3:-dev}

print_header

# Verificar se está no diretório correto
if [ ! -f "README.md" ] || [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
    print_error "Execute este script na raiz do projeto Game.Servers"
    exit 1
fi

# Verificar se o provedor é suportado
case $PROVIDER in
    digitalocean|hostinger|aws|azure|linode|vultr)
        print_message "Provedor: $PROVIDER"
        ;;
    *)
        print_error "Provedor não suportado: $PROVIDER"
        exit 1
        ;;
esac

# Verificar se o jogo é suportado
case $GAME_TYPE in
    sotf|minecraft|valheim|rust|ark)
        print_message "Jogo: $GAME_TYPE"
        ;;
    *)
        print_error "Jogo não suportado: $GAME_TYPE"
        exit 1
        ;;
esac

print_message "Ambiente: $ENVIRONMENT"

# Verificar dependências
print_message "Verificando dependências..."

if ! command -v terraform &> /dev/null; then
    print_error "Terraform não encontrado. Instale em: https://terraform.io/downloads"
    exit 1
fi

if ! command -v ansible &> /dev/null; then
    print_error "Ansible não encontrado. Instale com: pip install ansible"
    exit 1
fi

print_message "Dependências verificadas!"

# Configurar arquivos
print_message "Configurando arquivos para $PROVIDER..."

# Copiar configuração do provedor
if [ -f "terraform/environments/${PROVIDER}.tfvars" ]; then
    cp terraform/environments/${PROVIDER}.tfvars terraform/terraform.tfvars
    print_message "Configuração do provedor copiada"
else
    print_warning "Arquivo de configuração do provedor não encontrado: terraform/environments/${PROVIDER}.tfvars"
    print_message "Criando configuração básica..."
    
    # Configurações específicas por provedor
    case $PROVIDER in
        vultr)
            REGION="sao-paulo"
            INSTANCE_SIZE="vc2-1c-1gb"
            ;;
        digitalocean)
            REGION="nyc3"
            INSTANCE_SIZE="s-2vcpu-8gb"
            ;;
        hostinger)
            REGION="brazil"
            INSTANCE_SIZE="game-panel-1"
            ;;
        aws)
            REGION="us-east-1"
            INSTANCE_SIZE="t3.medium"
            ;;
        azure)
            REGION="eastus"
            INSTANCE_SIZE="Standard_B2s"
            ;;
        linode)
            REGION="us-east"
            INSTANCE_SIZE="g6-nanode-1"
            ;;
        *)
            REGION="nyc3"
            INSTANCE_SIZE="s-2vcpu-8gb"
            ;;
    esac
    
    # Criar configuração básica
    cat > terraform/terraform.tfvars << EOF
# Configuração para $PROVIDER
provider = "$PROVIDER"
game_type = "$GAME_TYPE"
server_name = "MeuServidor${GAME_TYPE^}"
server_password = "minha-senha-segura"
max_players = 8
environment = "$ENVIRONMENT"
region = "$REGION"
instance_size = "$INSTANCE_SIZE"
plan_id = "$INSTANCE_SIZE"
EOF
fi

# Configurar ambiente
if [ -f "terraform/environments/${ENVIRONMENT}.tfvars" ]; then
    print_message "Aplicando configurações do ambiente $ENVIRONMENT..."
    # Aplicar configurações do ambiente
    cat terraform/environments/${ENVIRONMENT}.tfvars >> terraform/terraform.tfvars
fi

# Inicializar Terraform
print_message "Inicializando Terraform..."
cd terraform

# Usar configuração universal
if [ -f "main-universal.tf" ]; then
    print_message "Usando configuração universal..."
    terraform init
else
    print_error "Arquivo main-universal.tf não encontrado"
    exit 1
fi

# Planejar mudanças
print_message "Planejando mudanças..."
terraform plan -var="provider=$PROVIDER" -var="game_type=$GAME_TYPE"

# Confirmar deploy
echo ""
print_warning "Deseja continuar com o deploy? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_message "Deploy cancelado"
    exit 0
fi

# Aplicar mudanças
print_message "Aplicando mudanças..."
terraform apply -var="provider=$PROVIDER" -var="game_type=$GAME_TYPE" -auto-approve

# Mostrar informações do servidor
print_message "Deploy concluído!"
echo ""
print_header "Informações do Servidor"
echo "IP: $(terraform output -raw server_ip)"
echo "Nome: $(terraform output -raw server_name)"
echo "Provedor: $PROVIDER"
echo "Jogo: $GAME_TYPE"
echo "Ambiente: $ENVIRONMENT"
echo ""

# Mostrar informações de conexão
case $GAME_TYPE in
    sotf)
        echo "Para conectar no Sons of the Forest:"
        echo "  IP: $(terraform output -raw server_ip):8766"
        ;;
    minecraft)
        echo "Para conectar no Minecraft:"
        echo "  IP: $(terraform output -raw server_ip):25565"
        ;;
    valheim)
        echo "Para conectar no Valheim:"
        echo "  IP: $(terraform output -raw server_ip):2456"
        ;;
    rust)
        echo "Para conectar no Rust:"
        echo "  IP: $(terraform output -raw server_ip):28015"
        ;;
    ark)
        echo "Para conectar no ARK:"
        echo "  IP: $(terraform output -raw server_ip):7777"
        ;;
esac

echo ""
print_message "Deploy concluído com sucesso! 🎮"

cd ..
