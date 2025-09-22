# Setup do Game.Servers com AWS EC2

Este guia cobre o provisionamento completo de servidores de jogos usando AWS EC2 através do Game.Servers.

## 📋 Pré-requisitos

### Ferramentas Necessárias
- **Terraform** >= 1.5.0
- **Ansible** >= 2.15.0
- **Git** (para versionamento)
- **SSH** configurado
- **AWS CLI** (opcional, mas recomendado)

### Contas e Credenciais
- Conta AWS com permissões de EC2
- Access Key ID e Secret Access Key
- Key Pair SSH cadastrada na AWS
- Acesso ao console AWS

## 🔑 Configuração da AWS

### 1. Criar Usuário IAM

1. Acesse o [Console AWS IAM](https://console.aws.amazon.com/iam/)
2. Vá para **Users** > **Create user**
3. Nome: `game-servers-user`
4. Anexe a política: `AmazonEC2FullAccess`
5. Crie Access Key ID e Secret Access Key
6. **IMPORTANTE**: Salve as credenciais em local seguro

### 2. Configurar Key Pair SSH

1. Acesse o [Console EC2](https://console.aws.amazon.com/ec2/)
2. Vá para **Key Pairs** > **Create key pair**
3. Nome: `game-servers-key`
4. Tipo: RSA
5. Formato: .pem
6. Baixe o arquivo .pem
7. Configure permissões: `chmod 400 game-servers-key.pem`

### 3. Verificar Regiões Disponíveis

A AWS oferece VPS em várias regiões:
- **América do Norte**: us-east-1, us-west-2, us-west-1
- **Europa**: eu-west-1, eu-central-1, eu-west-2
- **Ásia**: ap-southeast-1, ap-northeast-1, ap-south-1
- **América do Sul**: sa-east-1

## 🚀 Quick Start com AWS

### 1. Configuração Inicial

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/Game.Servers.git
cd Game.Servers

# Configure as variáveis
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

### 2. Editar Configurações para AWS

Edite o arquivo `terraform/terraform.tfvars`:

```hcl
# Credenciais AWS
provider = "aws"
aws_access_key = "sua-access-key-id"
aws_secret_key = "sua-secret-access-key"
ssh_key_name = "game-servers-key"

# Configuração do servidor
server_name = "MeuServidorSotF"
game_type = "sotf"
server_password = "minha-senha-segura"
max_players = 8

# Infraestrutura AWS
environment = "dev"
region = "us-east-1"
instance_size = "t3.medium"
```

### 3. Deploy do Servidor

```bash
# Deploy universal
./scripts/deploy-universal.sh aws sotf

# Ou deploy manual
cd terraform
terraform init
terraform apply -var="provider=aws" -var="game_type=sotf"
```

## ⚙️ Configurações Avançadas da AWS

### Tipos de Instância Recomendados

```hcl
# Sons of the Forest
instance_size = "t3.large"    # 2 vCPU, 8GB RAM - $0.0832/hora
instance_size = "t3.xlarge"   # 4 vCPU, 16GB RAM - $0.1664/hora

# Minecraft
instance_size = "t3.medium"   # 2 vCPU, 4GB RAM - $0.0416/hora
instance_size = "t3.large"    # 2 vCPU, 8GB RAM - $0.0832/hora

# Valheim
instance_size = "t3.medium"   # 2 vCPU, 4GB RAM - $0.0416/hora
instance_size = "t3.large"    # 2 vCPU, 8GB RAM - $0.0832/hora

# Rust
instance_size = "t3.large"    # 2 vCPU, 8GB RAM - $0.0832/hora
instance_size = "t3.xlarge"   # 4 vCPU, 16GB RAM - $0.1664/hora

# ARK
instance_size = "t3.xlarge"   # 4 vCPU, 16GB RAM - $0.1664/hora
instance_size = "t3.2xlarge"  # 8 vCPU, 32GB RAM - $0.3328/hora
```

### Configurações de Storage

```hcl
# EBS Volume Types
gp3 = {
  type = "gp3"
  size = 20
  iops = 3000
  throughput = 125
  cost = "$0.08/GB/mês"
}

gp2 = {
  type = "gp2"
  size = 20
  cost = "$0.10/GB/mês"
}

io1 = {
  type = "io1"
  size = 20
  iops = 1000
  cost = "$0.125/GB/mês + $0.065/IOPS/mês"
}
```

### Security Groups

```hcl
# Security Group para Sons of the Forest
ingress_rules = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  },
  {
    from_port   = 8766
    to_port     = 8766
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Sons of the Forest TCP"
  },
  {
    from_port   = 8766
    to_port     = 8766
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Sons of the Forest UDP"
  }
]
```

## 🎮 Configuração por Jogo

### Sons of the Forest

```hcl
# Configuração recomendada para SotF
game_type = "sotf"
instance_size = "t3.large"  # 2 vCPU, 8GB RAM
region = "us-east-1"
max_players = 8
assign_eip = true
```

### Minecraft

```hcl
# Configuração recomendada para Minecraft
game_type = "minecraft"
instance_size = "t3.medium"  # 2 vCPU, 4GB RAM
region = "us-east-1"
max_players = 20
minecraft_java_opts = "-Xmx3G -Xms2G"
```

### Valheim

```hcl
# Configuração recomendada para Valheim
game_type = "valheim"
instance_size = "t3.medium"  # 2 vCPU, 4GB RAM
region = "us-east-1"
max_players = 10
valheim_world_name = "Dedicated"
```

## 🔧 Troubleshooting AWS

### Problemas Comuns

#### Instância não cria
```bash
# Verificar credenciais
aws sts get-caller-identity

# Verificar região
terraform plan -var="region=us-east-1"

# Verificar key pair
aws ec2 describe-key-pairs --key-names game-servers-key
```

#### SSH não conecta
```bash
# Verificar key pair
aws ec2 describe-key-pairs --key-names game-servers-key

# Verificar security group
aws ec2 describe-security-groups --group-names "sotf-MeuServidorSotF-sg"

# Testar conexão
ssh -i game-servers-key.pem ec2-user@IP_DO_SERVIDOR
```

#### Security Group bloqueia
```bash
# Verificar regras
aws ec2 describe-security-groups --group-names "sotf-MeuServidorSotF-sg"

# Adicionar regra manualmente
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 8766 \
  --cidr 0.0.0.0/0
```

### Logs e Monitoramento

#### CloudWatch Logs
```bash
# Verificar logs do sistema
aws logs describe-log-groups --log-group-name-prefix "/aws/ec2"

# Ver logs específicos
aws logs get-log-events \
  --log-group-name "/aws/ec2/game-server" \
  --log-stream-name "i-1234567890abcdef0"
```

#### CloudWatch Metrics
```bash
# Ver métricas da instância
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

## 💰 Custos e Otimização

### Estimativa de Custos

| Jogo | Tipo de Instância | Custo/Hora | Custo/Mês | Jogadores |
|------|------------------|------------|-----------|-----------|
| Sons of the Forest | t3.large | $0.0832 | ~$60 | 8 |
| Minecraft | t3.medium | $0.0416 | ~$30 | 20 |
| Valheim | t3.medium | $0.0416 | ~$30 | 10 |
| Rust | t3.large | $0.0832 | ~$60 | 50 |
| ARK | t3.xlarge | $0.1664 | ~$120 | 20 |

### Dicas de Otimização

1. **Use Spot Instances** para desenvolvimento
2. **Configure Auto Scaling** para picos de uso
3. **Use Reserved Instances** para produção
4. **Monitore custos** com AWS Cost Explorer
5. **Configure alertas** de billing

### Spot Instances

```hcl
# Configuração para Spot Instance
spot_price = "0.05"  # Preço máximo por hora
spot_type = "one-time"  # one-time ou persistent
```

## 🔄 Atualizações e Manutenção

### Atualizar Servidor

```bash
# Via Ansible
cd ansible
ansible-playbook -i IP_DO_SERVIDOR, playbooks/update-game.yml \
  --extra-vars "game_type=sotf" \
  --extra-vars "provider=aws"
```

### Backup de Saves

```bash
# Backup para S3
aws s3 cp /opt/gameservers/sotf/saves/ s3://meu-bucket/saves/ --recursive

# Restaurar do S3
aws s3 cp s3://meu-bucket/saves/ /opt/gameservers/sotf/saves/ --recursive
```

### Snapshot da Instância

```bash
# Criar snapshot
aws ec2 create-snapshot \
  --volume-id vol-1234567890abcdef0 \
  --description "Backup do servidor SotF"

# Listar snapshots
aws ec2 describe-snapshots --owner-ids self
```

## 📊 Monitoramento Avançado

### CloudWatch Dashboard

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "CPU Utilization"
      }
    }
  ]
}
```

### Alertas CloudWatch

```bash
# Criar alarme de CPU
aws cloudwatch put-metric-alarm \
  --alarm-name "High CPU Usage" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2
```

## 🆘 Suporte

### Recursos da AWS

- **Documentação**: [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- **Suporte**: [AWS Support](https://console.aws.amazon.com/support/)
- **Status**: [AWS Status](https://status.aws.amazon.com/)
- **Pricing Calculator**: [AWS Pricing Calculator](https://calculator.aws/)

### Recursos do Game.Servers

- **GitHub Issues**: [Link para issues]
- **Discord**: [Link para Discord]
- **Email**: [Seu email]

## 📚 Próximos Passos

1. **Configure suas credenciais** da AWS
2. **Teste com uma instância pequena** (t3.micro)
3. **Monitore custos** com AWS Cost Explorer
4. **Configure backup automático** para S3
5. **Implemente monitoramento** com CloudWatch

---

**Nota**: Este guia é específico para AWS. Para outros provedores, consulte a documentação específica de cada um.
