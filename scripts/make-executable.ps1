# Script PowerShell para tornar arquivos executáveis no Windows

Write-Host "🔧 Tornando scripts executáveis..." -ForegroundColor Green

# Lista de scripts para tornar executáveis
$scripts = @(
    "verify-dependencies.sh",
    "verify-provider-credentials.sh", 
    "verify-server-deployment.sh",
    "deploy-with-verification.sh",
    "deploy-universal.sh",
    "production-deploy.sh",
    "setup-vultr.sh",
    "test-vultr.sh"
)

foreach ($script in $scripts) {
    $scriptPath = "scripts\$script"
    if (Test-Path $scriptPath) {
        Write-Host "✅ $script encontrado" -ForegroundColor Green
        # No Windows, os arquivos .sh são executados via Git Bash ou WSL
        # Não precisamos alterar permissões como no Linux
    }
    else {
        Write-Host "❌ $script não encontrado" -ForegroundColor Red
    }
}

Write-Host "🎉 Scripts prontos para uso!" -ForegroundColor Green
Write-Host ""
Write-Host "Para executar no Windows:" -ForegroundColor Yellow
Write-Host "1. Use Git Bash: bash scripts/verify-dependencies.sh" -ForegroundColor Cyan
Write-Host "2. Use WSL: wsl bash scripts/verify-dependencies.sh" -ForegroundColor Cyan
Write-Host "3. Use PowerShell: bash scripts/verify-dependencies.sh" -ForegroundColor Cyan
