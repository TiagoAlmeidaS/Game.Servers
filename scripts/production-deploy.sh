#!/bin/bash
# Script de deploy para produção do Game.Servers

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
    echo -e "${BLUE}  Game.Servers - Production Deploy${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar parâmetros
if [ $# -lt 3 ]; then
    print_error "Uso: $0 <provedor> <jogo> <ambiente> [configurações]"
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
    echo "Ambientes:"
    echo "  - dev"
    echo "  - staging"
    echo "  - prod"
    echo ""
    echo "Exemplo: $0 aws sotf prod --monitoring --backup --scaling"
    exit 1
fi

PROVIDER=$1
GAME_TYPE=$2
ENVIRONMENT=$3
shift 3

# Parse argumentos adicionais
MONITORING=false
BACKUP=false
SCALING=false
ALERTS=false
LOGGING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --monitoring)
            MONITORING=true
            shift
            ;;
        --backup)
            BACKUP=true
            shift
            ;;
        --scaling)
            SCALING=true
            shift
            ;;
        --alerts)
            ALERTS=true
            shift
            ;;
        --logging)
            LOGGING=true
            shift
            ;;
        *)
            print_error "Argumento desconhecido: $1"
            exit 1
            ;;
    esac
done

print_header

# Verificar se está no diretório correto
if [ ! -f "README.md" ] || [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
    print_error "Execute este script na raiz do projeto Game.Servers"
    exit 1
fi

# Verificar se é ambiente de produção
if [ "$ENVIRONMENT" = "prod" ]; then
    print_warning "ATENÇÃO: Deploy em ambiente de PRODUÇÃO!"
    echo "Deseja continuar? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_message "Deploy cancelado"
        exit 0
    fi
fi

# Verificar dependências
print_message "Verificando dependências..."

if ! command -v terraform &> /dev/null; then
    print_error "Terraform não encontrado"
    exit 1
fi

if ! command -v ansible &> /dev/null; then
    print_error "Ansible não encontrado"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    print_error "jq não encontrado"
    exit 1
fi

print_message "Dependências verificadas!"

# Configurar arquivos
print_message "Configurando arquivos para $PROVIDER ($ENVIRONMENT)..."

# Copiar configuração do provedor
if [ -f "terraform/environments/${PROVIDER}.tfvars" ]; then
    cp terraform/environments/${PROVIDER}.tfvars terraform/terraform.tfvars
    print_message "Configuração do provedor copiada"
else
    print_error "Arquivo de configuração do provedor não encontrado: terraform/environments/${PROVIDER}.tfvars"
    exit 1
fi

# Configurar ambiente
if [ -f "terraform/environments/${ENVIRONMENT}.tfvars" ]; then
    print_message "Aplicando configurações do ambiente $ENVIRONMENT..."
    cat terraform/environments/${ENVIRONMENT}.tfvars >> terraform/terraform.tfvars
fi

# Adicionar configurações de produção
cat >> terraform/terraform.tfvars << EOF

# Configurações de produção
enable_monitoring = ${MONITORING}
enable_backup = ${BACKUP}
enable_scaling = ${SCALING}
enable_alerts = ${ALERTS}
enable_logging = ${LOGGING}
EOF

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

# Validar configuração
print_message "Validando configuração..."
terraform validate

# Planejar mudanças
print_message "Planejando mudanças..."
terraform plan -var="provider=$PROVIDER" -var="game_type=$GAME_TYPE" -var="environment=$ENVIRONMENT"

# Confirmar deploy
echo ""
print_warning "Deseja continuar com o deploy de PRODUÇÃO? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    print_message "Deploy cancelado"
    exit 0
fi

# Aplicar mudanças
print_message "Aplicando mudanças..."
terraform apply -var="provider=$PROVIDER" -var="game_type=$GAME_TYPE" -var="environment=$ENVIRONMENT" -auto-approve

# Configurar monitoramento
if [ "$MONITORING" = true ]; then
    print_message "Configurando monitoramento..."
    cd ../ansible
    ansible-playbook -i $(terraform output -raw server_ip), playbooks/setup-monitoring.yml \
      --extra-vars "game_type=$GAME_TYPE" \
      --extra-vars "provider=$PROVIDER" \
      --extra-vars "environment=$ENVIRONMENT" \
      --user=root \
      --private-key=~/.ssh/id_rsa
fi

# Configurar backup
if [ "$BACKUP" = true ]; then
    print_message "Configurando backup..."
    ansible-playbook -i $(terraform output -raw server_ip), playbooks/setup-backup.yml \
      --extra-vars "game_type=$GAME_TYPE" \
      --extra-vars "provider=$PROVIDER" \
      --extra-vars "environment=$ENVIRONMENT" \
      --user=root \
      --private-key=~/.ssh/id_rsa
fi

# Configurar alertas
if [ "$ALERTS" = true ]; then
    print_message "Configurando alertas..."
    ansible-playbook -i $(terraform output -raw server_ip), playbooks/setup-alerts.yml \
      --extra-vars "game_type=$GAME_TYPE" \
      --extra-vars "provider=$PROVIDER" \
      --extra-vars "environment=$ENVIRONMENT" \
      --user=root \
      --private-key=~/.ssh/id_rsa
fi

# Configurar logging
if [ "$LOGGING" = true ]; then
    print_message "Configurando logging..."
    ansible-playbook -i $(terraform output -raw server_ip), playbooks/setup-logging.yml \
      --extra-vars "game_type=$GAME_TYPE" \
      --extra-vars "provider=$PROVIDER" \
      --extra-vars "environment=$ENVIRONMENT" \
      --user=root \
      --private-key=~/.ssh/id_rsa
fi

# Mostrar informações do servidor
print_message "Deploy de produção concluído!"
echo ""
print_header "Informações do Servidor"
echo "IP: $(terraform output -raw server_ip)"
echo "Nome: $(terraform output -raw server_name)"
echo "Provedor: $PROVIDER"
echo "Jogo: $GAME_TYPE"
echo "Ambiente: $ENVIRONMENT"
echo "Monitoramento: $MONITORING"
echo "Backup: $BACKUP"
echo "Scaling: $SCALING"
echo "Alertas: $ALERTS"
echo "Logging: $LOGGING"
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
print_message "Deploy de produção concluído com sucesso! 🎮"

cd ..
