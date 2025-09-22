# Configuração universal do Game.Servers
# Funciona com qualquer provedor de cloud

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    # Provedores dinâmicos baseados na variável provider
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    hostinger = {
      source  = "hostinger/hostinger"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azure = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 1.0"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Configuração dinâmica de provedores
locals {
  providers = {
    digitalocean = {
      source = "./modules/vps-base-digitalocean"
      config = {
        do_token      = var.do_token
        ssh_key_id    = var.ssh_key_id
        region        = var.region
        instance_size = var.instance_size
      }
    }
    hostinger = {
      source = "./modules/vps-base-hostinger"
      config = {
        hostinger_api_key = var.hostinger_api_key
        ssh_key_id        = var.ssh_key_id
        region            = var.region
        instance_size     = var.instance_size
      }
    }
    aws = {
      source = "./modules/vps-base-aws"
      config = {
        aws_access_key = var.aws_access_key
        aws_secret_key = var.aws_secret_key
        ssh_key_name   = var.ssh_key_name
        region         = var.region
        instance_size  = var.instance_size
      }
    }
    azure = {
      source = "./modules/vps-base-azure"
      config = {
        azure_client_id     = var.azure_client_id
        azure_client_secret = var.azure_client_secret
        ssh_key_name        = var.ssh_key_name
        region              = var.region
        instance_size       = var.instance_size
      }
    }
    linode = {
      source = "./modules/vps-base-linode"
      config = {
        linode_token    = var.linode_token
        ssh_key_id      = var.ssh_key_id
        region          = var.region
        instance_size   = var.instance_size
      }
    }
    vultr = {
      source = "./modules/vps-base-vultr"
      config = {
        vultr_api_key   = var.vultr_api_key
        ssh_key_id      = var.ssh_key_id
        region          = var.region
        instance_size   = var.instance_size
      }
    }
  }
}

# Módulo dinâmico baseado no provedor escolhido
module "vps_base" {
  source = local.providers[var.provider].source

  # Configurações comuns
  server_name   = var.server_name
  game_type     = var.game_type
  environment   = var.environment
  game_ports    = var.game_ports

  # Configurações específicas do provedor
  for_each = local.providers[var.provider].config
  each.key = each.value
}

# Configuração do servidor via Ansible
resource "null_resource" "configure_game_server" {
  depends_on = [module.vps_base]

  # Trigger para reconfigurar quando variáveis mudarem
  triggers = {
    server_ip       = module.vps_base.server_ip
    game_type       = var.game_type
    server_name     = var.server_name
    server_password = var.server_password
    provider        = var.provider
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ../ansible
      ansible-playbook \
        -i ${module.vps_base.server_ip}, \
        playbooks/deploy-game.yml \
        --extra-vars "game_type=${var.game_type}" \
        --extra-vars "server_name=${var.server_name}" \
        --extra-vars "server_password=${var.server_password}" \
        --extra-vars "max_players=${var.max_players}" \
        --extra-vars "server_ip=${module.vps_base.server_ip}" \
        --extra-vars "provider=${var.provider}" \
        --user=root \
        --private-key=${var.ssh_private_key_path}
    EOT
  }

  # Cleanup quando destruir
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      cd ../ansible
      ansible-playbook \
        -i ${self.triggers.server_ip}, \
        playbooks/cleanup-game.yml \
        --extra-vars "game_type=${self.triggers.game_type}" \
        --extra-vars "provider=${self.triggers.provider}" \
        --user=root \
        --private-key=${var.ssh_private_key_path}
    EOT
  }
}
