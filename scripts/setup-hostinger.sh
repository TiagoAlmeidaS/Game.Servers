#!/bin/bash
# Script de setup específico para Hostinger VPS

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
    echo -e "${BLUE}  Game.Servers - Hostinger Setup${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar se está no diretório correto
if [ ! -f "README.md" ] || [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
    print_error "Execute este script na raiz do projeto Game.Servers"
    exit 1
fi

print_header

# Verificar dependências
print_message "Verificando dependências..."

# Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform não encontrado. Instale em: https://terraform.io/downloads"
    exit 1
else
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_message "Terraform encontrado: $TERRAFORM_VERSION"
fi

# Ansible
if ! command -v ansible &> /dev/null; then
    print_error "Ansible não encontrado. Instale com: pip install ansible"
    exit 1
else
    ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2)
    print_message "Ansible encontrado: $ANSIBLE_VERSION"
fi

# Git
if ! command -v git &> /dev/null; then
    print_error "Git não encontrado. Instale em: https://git-scm.com/downloads"
    exit 1
else
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_message "Git encontrado: $GIT_VERSION"
fi

# jq (para parsing JSON)
if ! command -v jq &> /dev/null; then
    print_warning "jq não encontrado. Instalando..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y jq
    elif command -v yum &> /dev/null; then
        sudo yum install -y jq
    elif command -v brew &> /dev/null; then
        brew install jq
    else
        print_error "Não foi possível instalar jq automaticamente. Instale manualmente."
        exit 1
    fi
fi

print_message "Todas as dependências estão instaladas!"

# Configurar arquivos de exemplo
print_message "Configurando arquivos para Hostinger..."

# Terraform
if [ ! -f "terraform/terraform.tfvars" ]; then
    cp terraform/terraform.tfvars.hostinger.example terraform/terraform.tfvars
    print_message "Arquivo terraform.tfvars criado. Configure suas credenciais da Hostinger."
else
    print_warning "Arquivo terraform.tfvars já existe."
fi

# Ansible
if [ ! -f "ansible/inventory/hosts" ]; then
    cp ansible/inventory/hosts.example ansible/inventory/hosts
    print_message "Arquivo de inventário do Ansible criado."
else
    print_warning "Arquivo de inventário do Ansible já existe."
fi

# Inicializar Terraform
print_message "Inicializando Terraform..."
cd terraform
terraform init
cd ..

print_message "Setup inicial concluído!"

# Mostrar próximos passos
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Próximos Passos - Hostinger${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "1. Configure suas credenciais da Hostinger:"
echo "   - Acesse: https://hpanel.hostinger.com/"
echo "   - Vá para API > Generate New API Key"
echo "   - Copie a API Key e cole em terraform/terraform.tfvars"
echo ""
echo "2. Configure sua chave SSH:"
echo "   - No painel Hostinger, vá para SSH Keys"
echo "   - Adicione sua chave SSH pública"
echo "   - Anote o ID da chave e cole em terraform/terraform.tfvars"
echo ""
echo "3. Configure o servidor desejado:"
echo "   - server_name: Nome do seu servidor"
echo "   - game_type: sotf, minecraft, valheim, rust, ark"
echo "   - server_password: Senha do servidor"
echo "   - region: amsterdam, london, frankfurt, newyork, etc."
echo "   - instance_size: vps-1, vps-2, vps-3, vps-4, vps-5"
echo ""
echo "4. Deploy do servidor:"
echo "   cd terraform"
echo "   terraform apply"
echo ""
echo "5. Para mais informações, consulte:"
echo "   - docs/hostinger-setup.md"
echo "   - docs/sotf-setup.md"
echo "   - docs/minecraft-setup.md"
echo ""

# Verificar se há credenciais configuradas
if grep -q "sua-api-key-da-hostinger" terraform/terraform.tfvars; then
    print_warning "Lembre-se de configurar suas credenciais da Hostinger no terraform.tfvars!"
fi

# Mostrar informações sobre planos Hostinger
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Planos Hostinger Disponíveis${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "VPS 1: 1 CPU, 1GB RAM, 20GB SSD - €3.99/mês"
echo "VPS 2: 2 CPU, 2GB RAM, 40GB SSD - €7.99/mês"
echo "VPS 3: 3 CPU, 4GB RAM, 80GB SSD - €15.99/mês"
echo "VPS 4: 4 CPU, 8GB RAM, 160GB SSD - €31.99/mês"
echo "VPS 5: 6 CPU, 16GB RAM, 320GB SSD - €63.99/mês"
echo ""
echo "Recomendações por jogo:"
echo "- Sons of the Forest: VPS 3 (€15.99/mês)"
echo "- Minecraft: VPS 2 (€7.99/mês)"
echo "- Valheim: VPS 2 (€7.99/mês)"
echo "- Rust: VPS 4 (€31.99/mês)"
echo "- ARK: VPS 4 (€31.99/mês)"
echo ""

print_message "Setup concluído com sucesso! 🎮"
