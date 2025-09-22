#!/bin/bash
# Script de setup inicial do Game.Servers

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
    echo -e "${BLUE}  Game.Servers Setup Script${NC}"
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
print_message "Configurando arquivos de exemplo..."

# Terraform
if [ ! -f "terraform/terraform.tfvars" ]; then
    cp terraform/terraform.tfvars.example terraform/terraform.tfvars
    print_message "Arquivo terraform.tfvars criado. Configure suas credenciais."
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
echo -e "${BLUE}  Próximos Passos${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "1. Configure suas credenciais no arquivo terraform/terraform.tfvars:"
echo "   - do_token: Seu token do DigitalOcean"
echo "   - ssh_key_id: ID da sua chave SSH"
echo ""
echo "2. Configure o servidor desejado:"
echo "   - server_name: Nome do seu servidor"
echo "   - game_type: sotf, minecraft, valheim, rust, ark"
echo "   - server_password: Senha do servidor"
echo ""
echo "3. Deploy do servidor:"
echo "   cd terraform"
echo "   terraform apply"
echo ""
echo "4. Para mais informações, consulte a documentação em docs/"
echo ""

# Verificar se há credenciais configuradas
if grep -q "seu-token-do-digitalocean" terraform/terraform.tfvars; then
    print_warning "Lembre-se de configurar suas credenciais no terraform.tfvars!"
fi

print_message "Setup concluído com sucesso! 🎮"
