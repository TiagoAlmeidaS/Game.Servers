# Script de setup inicial do Game.Servers para Windows PowerShell

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

Write-Header "Game.Servers Setup Script"

# Verificar dependências
Write-Info "Verificando dependências..."

# Terraform
try {
    $terraformVersion = terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version
    Write-Info "Terraform encontrado: $terraformVersion"
}
catch {
    Write-Error "Terraform não encontrado. Instale em: https://terraform.io/downloads"
    exit 1
}

# Ansible
try {
    $ansibleVersion = ansible --version | Select-String "ansible" | ForEach-Object { $_.Line.Split(' ')[1] }
    Write-Info "Ansible encontrado: $ansibleVersion"
}
catch {
    Write-Error "Ansible não encontrado. Instale com: pip install ansible"
    exit 1
}

# Git
try {
    $gitVersion = git --version | ForEach-Object { $_.Split(' ')[2] }
    Write-Info "Git encontrado: $gitVersion"
}
catch {
    Write-Error "Git não encontrado. Instale em: https://git-scm.com/downloads"
    exit 1
}

# jq (opcional, mas recomendado)
try {
    jq --version | Out-Null
    Write-Info "jq encontrado"
}
catch {
    Write-Warning "jq não encontrado. Recomendado para parsing JSON. Instale em: https://jqlang.github.io/jq/"
}

Write-Info "Todas as dependências estão instaladas!"

# Configurar arquivos de exemplo
Write-Info "Configurando arquivos de exemplo..."

# Terraform
if (-not (Test-Path "terraform/terraform.tfvars")) {
    Copy-Item "terraform/terraform.tfvars.example" "terraform/terraform.tfvars"
    Write-Info "Arquivo terraform.tfvars criado. Configure suas credenciais."
}
else {
    Write-Warning "Arquivo terraform.tfvars já existe."
}

# Ansible
if (-not (Test-Path "ansible/inventory/hosts")) {
    Copy-Item "ansible/inventory/hosts.example" "ansible/inventory/hosts"
    Write-Info "Arquivo de inventário do Ansible criado."
}
else {
    Write-Warning "Arquivo de inventário do Ansible já existe."
}

# Inicializar Terraform
Write-Info "Inicializando Terraform..."
Set-Location terraform
terraform init
Set-Location ..

Write-Info "Setup inicial concluído!"

# Mostrar próximos passos
Write-Header "Próximos Passos"
Write-Host ""
Write-Host "1. Configure suas credenciais no arquivo terraform/terraform.tfvars:"
Write-Host "   - do_token: Seu token do DigitalOcean"
Write-Host "   - ssh_key_id: ID da sua chave SSH"
Write-Host ""
Write-Host "2. Configure o servidor desejado:"
Write-Host "   - server_name: Nome do seu servidor"
Write-Host "   - game_type: sotf, minecraft, valheim, rust, ark"
Write-Host "   - server_password: Senha do servidor"
Write-Host ""
Write-Host "3. Deploy do servidor:"
Write-Host "   cd terraform"
Write-Host "   terraform apply"
Write-Host ""
Write-Host "4. Para mais informações, consulte a documentação em docs/"
Write-Host ""

# Verificar se há credenciais configuradas
if ((Get-Content "terraform/terraform.tfvars") -match "seu-token-do-digitalocean") {
    Write-Warning "Lembre-se de configurar suas credenciais no terraform.tfvars!"
}

Write-Info "Setup concluído com sucesso! 🎮"
