# Módulo específico para AWS EC2
# Suporta provisionamento de instâncias EC2 na AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuração do provedor AWS
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Data source para AMI mais recente do Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group para o servidor de jogo
resource "aws_security_group" "game_sg" {
  name_prefix = "${var.game_type}-${var.server_name}"
  description = "Security group for ${var.game_type} game server"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Portas específicas do jogo
  dynamic "ingress" {
    for_each = var.game_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress - permitir tudo
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.game_type}-${var.server_name}-sg"
    Type = "game-server"
  }
}

# Instância EC2
resource "aws_instance" "game_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_size
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.game_sg.id]

  # IAM Instance Profile para CloudWatch
  iam_instance_profile = var.enable_cloudwatch ? aws_iam_instance_profile.game_server_profile[0].name : null

  # User data para configuração inicial
  user_data = templatefile("${path.module}/user_data.sh", {
    game_type = var.game_type
  })

  # Configurações de storage
  root_block_device {
    volume_type = "gp3"
    volume_size = var.disk_size
    encrypted   = true
  }

  # Configurações de monitoramento
  monitoring = var.enable_detailed_monitoring

  tags = {
    Name        = "${var.server_name}-${var.game_type}"
    Type        = "game-server"
    Game        = var.game_type
    Environment = var.environment
  }
}

# Elastic IP (opcional)
resource "aws_eip" "game_server_eip" {
  count    = var.assign_eip ? 1 : 0
  instance = aws_instance.game_server.id
  domain   = "vpc"

  tags = {
    Name = "${var.server_name}-${var.game_type}-eip"
    Type = "game-server"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "game_server_logs" {
  count             = var.enable_cloudwatch ? 1 : 0
  name              = "/aws/ec2/${var.server_name}-${var.game_type}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.server_name}-${var.game_type}-logs"
    Type = "game-server"
  }
}

# IAM Role para CloudWatch
resource "aws_iam_role" "game_server_role" {
  count = var.enable_cloudwatch ? 1 : 0
  name  = "${var.server_name}-${var.game_type}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.server_name}-${var.game_type}-role"
    Type = "game-server"
  }
}

# IAM Policy para CloudWatch
resource "aws_iam_policy" "game_server_policy" {
  count = var.enable_cloudwatch ? 1 : 0
  name  = "${var.server_name}-${var.game_type}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name = "${var.server_name}-${var.game_type}-policy"
    Type = "game-server"
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "game_server_policy_attachment" {
  count      = var.enable_cloudwatch ? 1 : 0
  role       = aws_iam_role.game_server_role[0].name
  policy_arn = aws_iam_policy.game_server_policy[0].arn
}

# Instance Profile
resource "aws_iam_instance_profile" "game_server_profile" {
  count = var.enable_cloudwatch ? 1 : 0
  name  = "${var.server_name}-${var.game_type}-profile"
  role  = aws_iam_role.game_server_role[0].name

  tags = {
    Name = "${var.server_name}-${var.game_type}-profile"
    Type = "game-server"
  }
}

# Outputs
output "server_ip" {
  description = "IP público do servidor"
  value       = var.assign_eip ? aws_eip.game_server_eip[0].public_ip : aws_instance.game_server.public_ip
}

output "server_id" {
  description = "ID da instância EC2"
  value       = aws_instance.game_server.id
}

output "server_name" {
  description = "Nome do servidor"
  value       = aws_instance.game_server.tags.Name
}

output "private_ip" {
  description = "IP privado do servidor"
  value       = aws_instance.game_server.private_ip
}
