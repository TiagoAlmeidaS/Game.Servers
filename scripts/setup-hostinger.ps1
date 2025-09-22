# Script de setup específico para Hostinger VPS - Windows PowerShell

param(
    [switch]$SkipDependencies
)

# Função para imprimir mensagens coloridas
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Header {
    param([string]$Message)
    Write-Host "================================" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "================================" -ForegroundColor Blue
}

# Verificar se está no diretório correto
if (-not (Test-Path "README.md") -or -not (Test-Path "terraform") -or -not (Test-Path "ansible")) {
    Write-Error "Execute este script na raiz do projeto Game.Servers"
    exit 1
}

Write-Header "Game.Servers - Hostinger Setup"

# Verificar dependências
Write-Info "Verificando dependências..."

# Terraform
try {
    $terraformVersion = terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version
    Write-Info "Terraform encontrado: $terraformVersion"
} catch {
    Write-Error "Terraform não encontrado. Instale em: https://terraform.io/downloads"
    exit 1
}

# Ansible
try {
    $ansibleVersion = ansible --version | Select-String "ansible" | ForEach-Object { $_.Line.Split(' ')[1] }
    Write-Info "Ansible encontrado: $ansibleVersion"
} catch {
    Write-Error "Ansible não encontrado. Instale com: pip install ansible"
    exit 1
}

# Git
try {
    $gitVersion = git --version | ForEach-Object { $_.Split(' ')[2] }
    Write-Info "Git encontrado: $gitVersion"
} catch {
    Write-Error "Git não encontrado. Instale em: https://git-scm.com/downloads"
    exit 1
}

# jq (opcional, mas recomendado)
try {
    jq --version | Out-Null
    Write-Info "jq encontrado"
} catch {
    Write-Warning "jq não encontrado. Recomendado para parsing JSON. Instale em: https://jqlang.github.io/jq/"
}

Write-Info "Todas as dependências estão instaladas!"

# Configurar arquivos de exemplo
Write-Info "Configurando arquivos para Hostinger..."

# Terraform
if (-not (Test-Path "terraform/terraform.tfvars")) {
    Copy-Item "terraform/terraform.tfvars.hostinger.example" "terraform/terraform.tfvars"
    Write-Info "Arquivo terraform.tfvars criado. Configure suas credenciais da Hostinger."
} else {
    Write-Warning "Arquivo terraform.tfvars já existe."
}

# Ansible
if (-not (Test-Path "ansible/inventory/hosts")) {
    Copy-Item "ansible/inventory/hosts.example" "ansible/inventory/hosts"
    Write-Info "Arquivo de inventário do Ansible criado."
} else {
    Write-Warning "Arquivo de inventário do Ansible já existe."
}

# Inicializar Terraform
Write-Info "Inicializando Terraform..."
Set-Location terraform
terraform init
Set-Location ..

Write-Info "Setup inicial concluído!"

# Mostrar próximos passos
Write-Header "Próximos Passos - Hostinger"
Write-Host ""
Write-Host "1. Configure suas credenciais da Hostinger:"
Write-Host "   - Acesse: https://hpanel.hostinger.com/"
Write-Host "   - Vá para API > Generate New API Key"
Write-Host "   - Copie a API Key e cole em terraform/terraform.tfvars"
Write-Host ""
Write-Host "2. Configure sua chave SSH:"
Write-Host "   - No painel Hostinger, vá para SSH Keys"
Write-Host "   - Adicione sua chave SSH pública"
Write-Host "   - Anote o ID da chave e cole em terraform/terraform.tfvars"
Write-Host ""
Write-Host "3. Configure o servidor desejado:"
Write-Host "   - server_name: Nome do seu servidor"
Write-Host "   - game_type: sotf, minecraft, valheim, rust, ark"
Write-Host "   - server_password: Senha do servidor"
Write-Host "   - region: amsterdam, london, frankfurt, newyork, etc."
Write-Host "   - instance_size: vps-1, vps-2, vps-3, vps-4, vps-5"
Write-Host ""
Write-Host "4. Deploy do servidor:"
Write-Host "   cd terraform"
Write-Host "   terraform apply"
Write-Host ""
Write-Host "5. Para mais informações, consulte:"
Write-Host "   - docs/hostinger-setup.md"
Write-Host "   - docs/sotf-setup.md"
Write-Host "   - docs/minecraft-setup.md"
Write-Host ""

# Verificar se há credenciais configuradas
if ((Get-Content "terraform/terraform.tfvars") -match "sua-api-key-da-hostinger") {
    Write-Warning "Lembre-se de configurar suas credenciais da Hostinger no terraform.tfvars!"
}

# Mostrar informações sobre planos Hostinger
Write-Header "Planos Hostinger Disponíveis"
Write-Host ""
Write-Host "VPS 1: 1 CPU, 1GB RAM, 20GB SSD - €3.99/mês"
Write-Host "VPS 2: 2 CPU, 2GB RAM, 40GB SSD - €7.99/mês"
Write-Host "VPS 3: 3 CPU, 4GB RAM, 80GB SSD - €15.99/mês"
Write-Host "VPS 4: 4 CPU, 8GB RAM, 160GB SSD - €31.99/mês"
Write-Host "VPS 5: 6 CPU, 16GB RAM, 320GB SSD - €63.99/mês"
Write-Host ""
Write-Host "Recomendações por jogo:"
Write-Host "- Sons of the Forest: VPS 3 (€15.99/mês)"
Write-Host "- Minecraft: VPS 2 (€7.99/mês)"
Write-Host "- Valheim: VPS 2 (€7.99/mês)"
Write-Host "- Rust: VPS 4 (€31.99/mês)"
Write-Host "- ARK: VPS 4 (€31.99/mês)"
Write-Host ""

Write-Info "Setup concluído com sucesso! 🎮"
