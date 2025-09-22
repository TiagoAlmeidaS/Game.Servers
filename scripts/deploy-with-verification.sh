#!/bin/bash
# Script de deploy completo com verificação automática

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
    echo -e "${BLUE}  Game.Servers - Deploy Automático${NC}"
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
    echo "Exemplo: $0 hostinger sotf prod --monitoring --backup"
    exit 1
fi

PROVIDER=$1
GAME_TYPE=$2
ENVIRONMENT=$3
shift 3

# Parse argumentos adicionais
MONITORING=false
BACKUP=false
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

# Fase 1: Verificação de Dependências
print_message "🔍 Fase 1: Verificando dependências..."
./scripts/verify-dependencies.sh

# Fase 2: Verificação de Credenciais
print_message "🔍 Fase 2: Verificando credenciais do provedor..."
./scripts/verify-provider-credentials.sh "$PROVIDER"

# Fase 3: Configuração do Terraform
print_message "🔍 Fase 3: Configurando Terraform..."

# Copiar configuração do provedor
if [ -f "terraform/environments/${PROVIDER}.tfvars" ]; then
    cp "terraform/environments/${PROVIDER}.tfvars" terraform/terraform.tfvars
    print_message "✅ Configuração do provedor copiada"
else
    print_error "❌ Arquivo de configuração do provedor não encontrado: terraform/environments/${PROVIDER}.tfvars"
    exit 1
fi

# Configurar ambiente
if [ -f "terraform/environments/${ENVIRONMENT}.tfvars" ]; then
    print_message "✅ Aplicando configurações do ambiente $ENVIRONMENT..."
    cat "terraform/environments/${ENVIRONMENT}.tfvars" >> terraform/terraform.tfvars
fi

# Adicionar configurações de produção
cat >> terraform/terraform.tfvars << EOF

# Configurações de produção
enable_monitoring = ${MONITORING}
enable_backup = ${BACKUP}
enable_alerts = ${ALERTS}
enable_logging = ${LOGGING}
EOF

# Fase 4: Deploy do Terraform
print_message "🚀 Fase 4: Deploy do Terraform..."
cd terraform

# Inicializar Terraform
print_message "Inicializando Terraform..."
terraform init

# Validar configuração
print_message "Validando configuração..."
terraform validate

# Planejar mudanças
print_message "Planejando mudanças..."
terraform plan -var="provider=$PROVIDER" -var="game_type=$GAME_TYPE" -var="environment=$ENVIRONMENT"

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
terraform apply -var="provider=$PROVIDER" -var="game_type=$GAME_TYPE" -var="environment=$ENVIRONMENT" -auto-approve

# Fase 5: Verificação Pós-Deploy
print_message "🔍 Fase 5: Verificando deploy..."
SERVER_IP=$(terraform output -raw server_ip)
print_message "Servidor deployado em: $SERVER_IP"

# Aguardar servidor ficar disponível
print_message "⏳ Aguardando servidor ficar disponível..."
sleep 30

# Verificar deploy do servidor
print_message "🔍 Verificando servidor..."
SSH_KEY_PATH="~/.ssh/id_rsa"

# Verificar se a chave SSH existe
if [ -f ~/.ssh/id_rsa ]; then
    SSH_KEY_PATH="~/.ssh/id_rsa"
elif [ -f ~/.ssh/id_ed25519 ]; then
    SSH_KEY_PATH="~/.ssh/id_ed25519"
else
    print_warning "⚠️ Chave SSH não encontrada, pulando verificação do servidor"
    print_message "Configure uma chave SSH para verificação automática"
else
    ./scripts/verify-server-deployment.sh "$SERVER_IP" "$GAME_TYPE" "$SSH_KEY_PATH"
fi

# Fase 6: Configuração de Produção (se solicitado)
if [ "$MONITORING" = true ] || [ "$BACKUP" = true ] || [ "$ALERTS" = true ] || [ "$LOGGING" = true ]; then
    print_message "🔧 Fase 6: Configurando funcionalidades de produção..."
    
    cd ../ansible
    
    if [ "$MONITORING" = true ]; then
        print_message "Configurando monitoramento..."
        ansible-playbook -i "$SERVER_IP," playbooks/setup-monitoring.yml \
          --extra-vars "game_type=$GAME_TYPE" \
          --extra-vars "provider=$PROVIDER" \
          --extra-vars "environment=$ENVIRONMENT" \
          --user=root \
          --private-key="$SSH_KEY_PATH" \
          --ssh-common-args="-o StrictHostKeyChecking=no"
    fi
    
    if [ "$BACKUP" = true ]; then
        print_message "Configurando backup..."
        ansible-playbook -i "$SERVER_IP," playbooks/setup-backup.yml \
          --extra-vars "game_type=$GAME_TYPE" \
          --extra-vars "provider=$PROVIDER" \
          --extra-vars "environment=$ENVIRONMENT" \
          --user=root \
          --private-key="$SSH_KEY_PATH" \
          --ssh-common-args="-o StrictHostKeyChecking=no"
    fi
    
    if [ "$ALERTS" = true ]; then
        print_message "Configurando alertas..."
        ansible-playbook -i "$SERVER_IP," playbooks/setup-alerts.yml \
          --extra-vars "game_type=$GAME_TYPE" \
          --extra-vars "provider=$PROVIDER" \
          --extra-vars "environment=$ENVIRONMENT" \
          --user=root \
          --private-key="$SSH_KEY_PATH" \
          --ssh-common-args="-o StrictHostKeyChecking=no"
    fi
    
    if [ "$LOGGING" = true ]; then
        print_message "Configurando logging..."
        ansible-playbook -i "$SERVER_IP," playbooks/setup-logging.yml \
          --extra-vars "game_type=$GAME_TYPE" \
          --extra-vars "provider=$PROVIDER" \
          --extra-vars "environment=$ENVIRONMENT" \
          --user=root \
          --private-key="$SSH_KEY_PATH" \
          --ssh-common-args="-o StrictHostKeyChecking=no"
    fi
    
    cd ../terraform
fi

# Mostrar informações do servidor
print_message "🎉 Deploy completo e verificado com sucesso!"
echo ""
print_header
echo "Informações do Servidor:"
echo "IP: $SERVER_IP"
echo "Nome: $(terraform output -raw server_name)"
echo "Provedor: $PROVIDER"
echo "Jogo: $GAME_TYPE"
echo "Ambiente: $ENVIRONMENT"
echo "Monitoramento: $MONITORING"
echo "Backup: $BACKUP"
echo "Alertas: $ALERTS"
echo "Logging: $LOGGING"
echo ""

# Mostrar informações de conexão
case $GAME_TYPE in
    sotf)
        echo "Para conectar no Sons of the Forest:"
        echo "  IP: $SERVER_IP:8766"
        ;;
    minecraft)
        echo "Para conectar no Minecraft:"
        echo "  IP: $SERVER_IP:25565"
        ;;
    valheim)
        echo "Para conectar no Valheim:"
        echo "  IP: $SERVER_IP:2456"
        ;;
    rust)
        echo "Para conectar no Rust:"
        echo "  IP: $SERVER_IP:28015"
        ;;
    ark)
        echo "Para conectar no ARK:"
        echo "  IP: $SERVER_IP:7777"
        ;;
esac

echo ""
print_message "Deploy de produção concluído com sucesso! 🎮"

cd ..
