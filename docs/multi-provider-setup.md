# Game.Servers - Suporte Multi-Provedor

O Game.Servers foi projetado para ser **agnóstico ao provedor**, funcionando com qualquer VPS. A arquitetura modular permite fácil adaptação para diferentes provedores de cloud.

## 🏗️ Arquitetura Multi-Provedor

### Princípio de Design
- **Terraform**: Módulos específicos por provedor
- **Ansible**: Roles genéricas que funcionam em qualquer VPS
- **Configuração**: Variáveis para escolher o provedor
- **Deploy**: Mesmo processo para todos os provedores

### Estrutura de Módulos
```
terraform/modules/
├── vps-base-digitalocean/     # Módulo para DigitalOcean
├── vps-base-hostinger/        # Módulo para Hostinger
├── vps-base-aws/              # Módulo para AWS
├── vps-base-azure/            # Módulo para Azure
├── vps-base-linode/           # Módulo para Linode
└── vps-base-vultr/            # Módulo para Vultr
```

## 🚀 Provedores Suportados

### ✅ Implementados
- **DigitalOcean**: Módulo completo
- **Hostinger**: Módulo completo

### 🔄 Em Desenvolvimento
- **AWS**: Módulo em desenvolvimento
- **Azure**: Módulo planejado
- **Linode**: Módulo planejado
- **Vultr**: Módulo planejado

## 🔧 Como Funciona

### 1. Escolha do Provedor
```hcl
# terraform/variables.tf
variable "provider" {
  description = "Provedor de cloud (digitalocean, hostinger, aws, azure, linode, vultr)"
  type        = string
  default     = "digitalocean"
}
```

### 2. Módulo Dinâmico
```hcl
# terraform/main.tf
module "vps_base" {
  source = "./modules/vps-base-${var.provider}"
  
  # Variáveis específicas do provedor
  api_key      = var.api_key
  ssh_key_id   = var.ssh_key_id
  server_name  = var.server_name
  game_type    = var.game_type
  # ... outras variáveis
}
```

### 3. Configuração por Provedor
```hcl
# terraform/terraform.tfvars
provider = "aws"  # ou digitalocean, hostinger, etc.
api_key = "sua-api-key"
region = "us-east-1"
instance_size = "t3.medium"
```

## 🌐 Exemplo: AWS

### Configuração AWS
```hcl
# terraform/terraform.tfvars.aws
provider = "aws"
aws_access_key = "sua-access-key"
aws_secret_key = "sua-secret-key"
region = "us-east-1"
instance_size = "t3.medium"
ssh_key_name = "sua-key-pair"
```

### Módulo AWS
```hcl
# terraform/modules/vps-base-aws/main.tf
resource "aws_instance" "game_server" {
  ami           = var.ami
  instance_type = var.instance_size
  key_name      = var.ssh_key_name
  
  vpc_security_group_ids = [aws_security_group.game_sg.id]
  
  user_data = templatefile("${path.module}/user_data.sh", {
    game_type = var.game_type
  })
  
  tags = {
    Name = "${var.server_name}-${var.game_type}"
    Type = "game-server"
  }
}
```

## 🔄 Migração Entre Provedores

### 1. Backup dos Dados
```bash
# Fazer backup dos saves
make backup
```

### 2. Destruir Infraestrutura Atual
```bash
# Destruir VPS atual
terraform destroy
```

### 3. Configurar Novo Provedor
```bash
# Editar terraform.tfvars
provider = "aws"  # Novo provedor
api_key = "nova-api-key"
region = "us-west-2"
```

### 4. Deploy no Novo Provedor
```bash
# Deploy no novo provedor
terraform apply
```

### 5. Restaurar Dados
```bash
# Restaurar saves
make restore-backup
```

## 📊 Comparação de Provedores

| Provedor | Custo | Performance | Regiões | Facilidade |
|----------|-------|-------------|---------|------------|
| **DigitalOcean** | € | ⭐⭐⭐⭐ | 8 | ⭐⭐⭐⭐⭐ |
| **Hostinger** | € | ⭐⭐⭐ | 7 | ⭐⭐⭐⭐ |
| **AWS** | $ | ⭐⭐⭐⭐⭐ | 25+ | ⭐⭐⭐ |
| **Azure** | $ | ⭐⭐⭐⭐⭐ | 60+ | ⭐⭐⭐ |
| **Linode** | $ | ⭐⭐⭐⭐ | 11 | ⭐⭐⭐⭐ |
| **Vultr** | $ | ⭐⭐⭐⭐ | 17 | ⭐⭐⭐⭐ |

## 🎯 Vantagens da Abordagem Multi-Provedor

### 1. **Flexibilidade**
- Escolha o provedor que melhor atende suas necessidades
- Migre facilmente entre provedores
- Evite vendor lock-in

### 2. **Custo-Otimização**
- Compare preços entre provedores
- Use o provedor mais barato para cada região
- Aproveite promoções e descontos

### 3. **Performance**
- Escolha a região mais próxima dos jogadores
- Use o provedor com melhor latência
- Otimize para cada tipo de jogo

### 4. **Confiabilidade**
- Distribua servidores em múltiplos provedores
- Reduza risco de downtime
- Implemente failover automático

## 🛠️ Implementação Prática

### 1. Estrutura de Arquivos
```
terraform/
├── main.tf                    # Configuração principal
├── variables.tf               # Variáveis globais
├── outputs.tf                 # Outputs globais
├── modules/
│   ├── vps-base-digitalocean/
│   ├── vps-base-hostinger/
│   ├── vps-base-aws/
│   └── vps-base-azure/
├── environments/
│   ├── digitalocean.tfvars
│   ├── hostinger.tfvars
│   ├── aws.tfvars
│   └── azure.tfvars
└── terraform.tfvars.example
```

### 2. Script de Deploy Universal
```bash
#!/bin/bash
# deploy.sh - Deploy universal para qualquer provedor

PROVIDER=${1:-digitalocean}
ENVIRONMENT=${2:-dev}

echo "Deploying to $PROVIDER ($ENVIRONMENT)..."

# Copiar configuração do provedor
cp terraform/environments/${PROVIDER}.tfvars terraform/terraform.tfvars

# Deploy
cd terraform
terraform init
terraform plan -var-file="environments/${ENVIRONMENT}.tfvars"
terraform apply -var-file="environments/${ENVIRONMENT}.tfvars"
```

### 3. Makefile Universal
```makefile
# Deploy para qualquer provedor
deploy-%:
	@echo "Deploying to $*..."
	@cp terraform/environments/$*.tfvars terraform/terraform.tfvars
	@cd terraform && terraform apply

# Deploy específico
deploy-aws:
	@$(MAKE) deploy-aws

deploy-digitalocean:
	@$(MAKE) deploy-digitalocean

deploy-hostinger:
	@$(MAKE) deploy-hostinger
```

## 🔧 Configuração por Provedor

### DigitalOcean
```hcl
provider = "digitalocean"
do_token = "seu-token"
region = "nyc3"
instance_size = "s-2vcpu-8gb"
```

### Hostinger
```hcl
provider = "hostinger"
hostinger_api_key = "sua-api-key"
region = "amsterdam"
instance_size = "vps-3"
```

### AWS
```hcl
provider = "aws"
aws_access_key = "sua-access-key"
aws_secret_key = "sua-secret-key"
region = "us-east-1"
instance_size = "t3.medium"
```

### Azure
```hcl
provider = "azure"
azure_client_id = "seu-client-id"
azure_client_secret = "seu-client-secret"
region = "eastus"
instance_size = "Standard_B2s"
```

## 🚀 Próximos Passos

### 1. **Implementar AWS**
- Criar módulo `vps-base-aws`
- Configurar security groups
- Implementar load balancer

### 2. **Implementar Azure**
- Criar módulo `vps-base-azure`
- Configurar resource groups
- Implementar availability sets

### 3. **Implementar Linode**
- Criar módulo `vps-base-linode`
- Configurar nodebalancer
- Implementar backups

### 4. **Implementar Vultr**
- Criar módulo `vps-base-vultr`
- Configurar firewall
- Implementar snapshots

## 📚 Recursos Adicionais

### Documentação por Provedor
- [DigitalOcean Setup](./digitalocean-setup.md)
- [Hostinger Setup](./hostinger-setup.md)
- [AWS Setup](./aws-setup.md) (em desenvolvimento)
- [Azure Setup](./azure-setup.md) (em desenvolvimento)

### Links Úteis
- [Terraform Providers](https://registry.terraform.io/browse/providers)
- [AWS EC2 Pricing](https://aws.amazon.com/ec2/pricing/)
- [Azure Virtual Machines](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/)
- [Linode Pricing](https://www.linode.com/pricing/)
- [Vultr Pricing](https://www.vultr.com/pricing/)

---

**Conclusão**: O Game.Servers foi projetado para ser **verdadeiramente multi-provedor**. Você pode usar qualquer VPS, migrar entre provedores facilmente, e aproveitar as melhores ofertas de cada um. A arquitetura modular torna isso possível! 🎮✨
