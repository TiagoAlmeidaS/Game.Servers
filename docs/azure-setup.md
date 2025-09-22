# Setup do Game.Servers com Azure Virtual Machines

Este guia cobre o provisionamento completo de servidores de jogos usando Azure VMs através do Game.Servers.

## 📋 Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.5.0
- **Ansible** >= 2.15.0
- **Git** (para versionamento)
- **SSH** configurado
- **Azure CLI** (opcional, mas recomendado)

### Contas e Credenciais
- Conta Azure com permissões de Virtual Machines
- Service Principal com permissões adequadas
- Chave SSH cadastrada na Azure
- Acesso ao portal Azure

## 🔑 Configuração da Azure

### 1. Criar Service Principal

1. Acesse o [Portal Azure](https://portal.azure.com/)
2. Vá para **Azure Active Directory** > **App registrations**
3. Clique em **New registration**
4. Nome: `game-servers-sp`
5. Copie o **Application (client) ID**
6. Vá para **Certificates & secrets** > **New client secret**
7. Copie o **Value** do secret
8. Vá para **Subscriptions** e copie o **Subscription ID**
9. Vá para **Azure Active Directory** > **Overview** e copie o **Tenant ID**

### 2. Configurar Permissões

1. Vá para **Subscriptions** > **Access control (IAM)**
2. Clique em **Add** > **Add role assignment**
3. Role: **Contributor**
4. Assign access to: **User, group, or service principal**
5. Select: `game-servers-sp`

### 3. Configurar Chave SSH

```bash
# Gerar chave SSH
ssh-keygen -t rsa -b 4096 -C "seu-email@exemplo.com"

# Copiar chave pública
cat ~/.ssh/id_rsa.pub
```

## 🚀 Quick Start com Azure

### 1. Configuração Inicial

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/Game.Servers.git
cd Game.Servers

# Configure as variáveis
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

### 2. Editar Configurações para Azure

Edite o arquivo `terraform/terraform.tfvars`:

```hcl
# Credenciais Azure
provider = "azure"
azure_client_id = "seu-client-id"
azure_client_secret = "seu-client-secret"
azure_subscription_id = "seu-subscription-id"
azure_tenant_id = "seu-tenant-id"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

# Configuração do servidor
server_name = "MeuServidorSotF"
game_type = "sotf"
server_password = "minha-senha-segura"
max_players = 8

# Infraestrutura Azure
environment = "dev"
region = "East US"
instance_size = "Standard_B2s"
```

### 3. Deploy do Servidor

```bash
# Deploy universal
./scripts/deploy-universal.sh azure sotf

# Ou deploy manual
cd terraform
terraform init
terraform apply -var="provider=azure" -var="game_type=sotf"
```

## ⚙️ Configurações Avançadas da Azure

### Tipos de Instância Recomendados

```hcl
# Sons of the Forest
instance_size = "Standard_B2s"    # 2 vCPU, 4GB RAM - $0.05/hora
instance_size = "Standard_B4s"    # 4 vCPU, 8GB RAM - $0.20/hora

# Minecraft
instance_size = "Standard_B1s"    # 1 vCPU, 1GB RAM - $0.01/hora
instance_size = "Standard_B2s"    # 2 vCPU, 4GB RAM - $0.05/hora

# Valheim
instance_size = "Standard_B2s"    # 2 vCPU, 4GB RAM - $0.05/hora
instance_size = "Standard_B4s"    # 4 vCPU, 8GB RAM - $0.20/hora

# Rust
instance_size = "Standard_B4s"    # 4 vCPU, 8GB RAM - $0.20/hora
instance_size = "Standard_D2s_v3" # 2 vCPU, 8GB RAM - $0.10/hora

# ARK
instance_size = "Standard_D4s_v3" # 4 vCPU, 16GB RAM - $0.20/hora
instance_size = "Standard_D8s_v3" # 8 vCPU, 32GB RAM - $0.40/hora
```

### Configurações de Storage

```hcl
# Managed Disks
Premium_LRS = {
  type = "Premium_LRS"
  size = 30
  cost = "$0.15/GB/mês"
}

Standard_LRS = {
  type = "Standard_LRS"
  size = 30
  cost = "$0.04/GB/mês"
}

StandardSSD_LRS = {
  type = "StandardSSD_LRS"
  size = 30
  cost = "$0.10/GB/mês"
}
```

## 🎮 Configuração por Jogo

### Sons of the Forest

```hcl
# Configuração recomendada para SotF
game_type = "sotf"
instance_size = "Standard_B4s"  # 4 vCPU, 8GB RAM
region = "East US"
max_players = 8
```

### Minecraft

```hcl
# Configuração recomendada para Minecraft
game_type = "minecraft"
instance_size = "Standard_B2s"  # 2 vCPU, 4GB RAM
region = "East US"
max_players = 20
minecraft_java_opts = "-Xmx3G -Xms2G"
```

## 🔧 Troubleshooting Azure

### Problemas Comuns

#### VM não cria
```bash
# Verificar credenciais
az login
az account show

# Verificar região
terraform plan -var="region=East US"

# Verificar resource group
az group list
```

#### SSH não conecta
```bash
# Verificar NSG
az network nsg list --resource-group MeuServidorSotF-sotf-rg

# Verificar regras
az network nsg rule list --resource-group MeuServidorSotF-sotf-rg --nsg-name sotf-MeuServidorSotF-nsg

# Testar conexão
ssh azureuser@IP_DO_SERVIDOR
```

### Logs e Monitoramento

#### Azure Monitor
```bash
# Ver logs da VM
az monitor activity-log list --resource-group MeuServidorSotF-sotf-rg

# Ver métricas
az monitor metrics list --resource MeuServidorSotF-sotf --metric "Percentage CPU"
```

## 💰 Custos e Otimização

### Estimativa de Custos

| Jogo | Tipo de Instância | Custo/Hora | Custo/Mês | Jogadores |
|------|------------------|------------|-----------|-----------|
| Sons of the Forest | Standard_B4s | $0.20 | ~$144 | 8 |
| Minecraft | Standard_B2s | $0.05 | ~$36 | 20 |
| Valheim | Standard_B2s | $0.05 | ~$36 | 10 |
| Rust | Standard_B4s | $0.20 | ~$144 | 50 |
| ARK | Standard_D4s_v3 | $0.20 | ~$144 | 20 |

### Dicas de Otimização

1. **Use Spot Instances** para desenvolvimento
2. **Configure Auto Scaling** para picos de uso
3. **Use Reserved Instances** para produção
4. **Monitore custos** com Azure Cost Management
5. **Configure alertas** de billing

## 🔄 Atualizações e Manutenção

### Atualizar Servidor

```bash
# Via Ansible
cd ansible
ansible-playbook -i IP_DO_SERVIDOR, playbooks/update-game.yml \
  --extra-vars "game_type=sotf" \
  --extra-vars "provider=azure"
```

### Backup de Saves

```bash
# Backup para Azure Storage
az storage blob upload-batch \
  --destination saves \
  --source /opt/gameservers/sotf/saves/ \
  --account-name meustorageaccount

# Restaurar do Azure Storage
az storage blob download-batch \
  --destination /opt/gameservers/sotf/saves/ \
  --source saves \
  --account-name meustorageaccount
```

## 📊 Monitoramento Avançado

### Azure Monitor Dashboard

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          {
            "namespace": "Microsoft.Compute/virtualMachines",
            "name": "Percentage CPU"
          }
        ],
        "timeRange": "PT1H",
        "title": "CPU Utilization"
      }
    }
  ]
}
```

### Alertas Azure Monitor

```bash
# Criar alerta de CPU
az monitor metrics alert create \
  --name "High CPU Usage" \
  --resource-group MeuServidorSotF-sotf-rg \
  --scopes /subscriptions/SUBSCRIPTION_ID/resourceGroups/MeuServidorSotF-sotf-rg/providers/Microsoft.Compute/virtualMachines/MeuServidorSotF-sotf \
  --condition "avg Percentage CPU > 80" \
  --description "Alert when CPU exceeds 80%"
```

## 🆘 Suporte

### Recursos da Azure

- **Documentação**: [Azure Virtual Machines Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- **Suporte**: [Azure Support](https://azure.microsoft.com/en-us/support/)
- **Status**: [Azure Status](https://status.azure.com/)
- **Pricing Calculator**: [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)

### Recursos do Game.Servers

- **GitHub Issues**: [Link para issues]
- **Discord**: [Link para Discord]
- **Email**: [Seu email]

## 📚 Próximos Passos

1. **Configure suas credenciais** da Azure
2. **Teste com uma instância pequena** (Standard_B1s)
3. **Monitore custos** com Azure Cost Management
4. **Configure backup automático** para Azure Storage
5. **Implemente monitoramento** com Azure Monitor

---

**Nota**: Este guia é específico para Azure. Para outros provedores, consulte a documentação específica de cada um.
