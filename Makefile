# Makefile para Game.Servers
# Facilita comandos comuns de desenvolvimento

.PHONY: help setup test clean deploy destroy lint format

# Variáveis
TERRAFORM_DIR = terraform
ANSIBLE_DIR = ansible
DOCS_DIR = docs

# Cores para output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## Mostra esta ajuda
	@echo "$(GREEN)Game.Servers - Comandos Disponíveis$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

setup: ## Configura o ambiente de desenvolvimento
	@echo "$(GREEN)Configurando ambiente de desenvolvimento...$(NC)"
	@if [ -f "scripts/setup.sh" ]; then \
		chmod +x scripts/setup.sh && ./scripts/setup.sh; \
	elif [ -f "scripts/setup.ps1" ]; then \
		powershell -ExecutionPolicy Bypass -File scripts/setup.ps1; \
	else \
		echo "$(RED)Script de setup não encontrado$(NC)"; \
	fi

init: ## Inicializa Terraform e Ansible
	@echo "$(GREEN)Inicializando Terraform...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform init
	@echo "$(GREEN)Configurando Ansible...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook --check playbooks/deploy-game.yml --extra-vars "game_type=sotf" --inventory localhost,

plan: ## Executa terraform plan
	@echo "$(GREEN)Executando terraform plan...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform plan

apply: ## Executa terraform apply
	@echo "$(GREEN)Executando terraform apply...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply

destroy: ## Executa terraform destroy
	@echo "$(RED)Executando terraform destroy...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform destroy

deploy-sotf: ## Deploy de servidor Sons of the Forest
	@echo "$(GREEN)Deploy de servidor Sons of the Forest...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply -var="game_type=sotf" -var="server_name=MeuServidorSotF"

deploy-minecraft: ## Deploy de servidor Minecraft
	@echo "$(GREEN)Deploy de servidor Minecraft...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply -var="game_type=minecraft" -var="server_name=MeuServidorMinecraft"

test: ## Executa testes
	@echo "$(GREEN)Executando testes...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform validate
	@cd $(ANSIBLE_DIR) && ansible-playbook --syntax-check playbooks/deploy-game.yml
	@cd $(ANSIBLE_DIR) && ansible-lint playbooks/ roles/

lint: ## Executa linting
	@echo "$(GREEN)Executando linting...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform fmt -check -recursive
	@cd $(ANSIBLE_DIR) && ansible-lint playbooks/ roles/

format: ## Formata código
	@echo "$(GREEN)Formatando código...$(NC)"
	@cd $(TERRAFORM_DIR) && terraform fmt -recursive
	@cd $(ANSIBLE_DIR) && ansible-lint --fix playbooks/ roles/

clean: ## Limpa arquivos temporários
	@echo "$(GREEN)Limpando arquivos temporários...$(NC)"
	@cd $(TERRAFORM_DIR) && rm -rf .terraform/ terraform.tfstate* .terraform.lock.hcl
	@cd $(ANSIBLE_DIR) && rm -rf .ansible/ *.retry
	@find . -name "*.log" -delete
	@find . -name ".DS_Store" -delete

docs: ## Gera documentação
	@echo "$(GREEN)Gerando documentação...$(NC)"
	@echo "Documentação disponível em $(DOCS_DIR)/"

docker-dev: ## Inicia ambiente de desenvolvimento com Docker
	@echo "$(GREEN)Iniciando ambiente de desenvolvimento...$(NC)"
	@docker-compose -f docker-compose.dev.yml up -d
	@echo "$(GREEN)Ambiente iniciado! Conecte com: docker exec -it game-servers-dev bash$(NC)"

docker-stop: ## Para ambiente de desenvolvimento
	@echo "$(GREEN)Parando ambiente de desenvolvimento...$(NC)"
	@docker-compose -f docker-compose.dev.yml down

status: ## Mostra status dos recursos
	@echo "$(GREEN)Status dos recursos:$(NC)"
	@cd $(TERRAFORM_DIR) && terraform show -json | jq -r '.values.root_module.resources[] | select(.type == "digitalocean_droplet") | "\(.values.name): \(.values.ipv4_address)"'

logs: ## Mostra logs do servidor
	@echo "$(GREEN)Logs do servidor:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "journalctl -u GAME_TYPE-server -f --no-pager" --inventory localhost,

backup: ## Faz backup dos saves
	@echo "$(GREEN)Fazendo backup dos saves...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "tar -czf /home/gameserver/backups/backup-$(shell date +%Y%m%d).tar.gz /opt/gameservers/*/saves/ /opt/gameservers/*/world/" --inventory localhost,

update: ## Atualiza servidor de jogo
	@echo "$(GREEN)Atualizando servidor de jogo...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook playbooks/update-game.yml --extra-vars "game_type=$(GAME_TYPE)" --inventory localhost,

monitor: ## Inicia monitoramento
	@echo "$(GREEN)Iniciando monitoramento...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "/home/gameserver/monitor.sh" --inventory localhost,

# Comandos específicos por jogo
sotf: ## Deploy rápido de Sons of the Forest
	@$(MAKE) deploy-sotf

minecraft: ## Deploy rápido de Minecraft
	@$(MAKE) deploy-minecraft

# Comandos de desenvolvimento
dev-setup: ## Setup completo para desenvolvimento
	@$(MAKE) setup
	@$(MAKE) init
	@$(MAKE) test

dev-clean: ## Limpeza completa do ambiente de desenvolvimento
	@$(MAKE) clean
	@$(MAKE) docker-stop

# Comandos de CI/CD
ci-test: ## Testes para CI/CD
	@$(MAKE) lint
	@$(MAKE) test

ci-deploy: ## Deploy para CI/CD
	@$(MAKE) apply

# Comandos de produção
prod-deploy: ## Deploy para produção
	@echo "$(RED)ATENÇÃO: Deploy para produção!$(NC)"
	@cd $(TERRAFORM_DIR) && terraform apply -var-file="environments/prod.tfvars"

prod-destroy: ## Destroy para produção
	@echo "$(RED)ATENÇÃO: Destroy para produção!$(NC)"
	@cd $(TERRAFORM_DIR) && terraform destroy -var-file="environments/prod.tfvars"

# Comandos de ajuda
list-games: ## Lista jogos suportados
	@echo "$(GREEN)Jogos suportados:$(NC)"
	@echo "  - sotf (Sons of the Forest)"
	@echo "  - minecraft (Minecraft)"
	@echo "  - valheim (Valheim) - em desenvolvimento"
	@echo "  - rust (Rust) - em desenvolvimento"
	@echo "  - ark (ARK: Survival Evolved) - em desenvolvimento"

list-commands: ## Lista comandos disponíveis
	@$(MAKE) help

# Comandos de debug
debug-terraform: ## Debug do Terraform
	@echo "$(GREEN)Debug do Terraform:$(NC)"
	@cd $(TERRAFORM_DIR) && terraform show

debug-ansible: ## Debug do Ansible
	@echo "$(GREEN)Debug do Ansible:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible-playbook --check -vvv playbooks/deploy-game.yml --extra-vars "game_type=sotf" --inventory localhost,

debug-connectivity: ## Testa conectividade
	@echo "$(GREEN)Testando conectividade:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m ping --inventory localhost,

# Comandos de manutenção
maintenance-backup: ## Backup de manutenção
	@$(MAKE) backup

maintenance-update: ## Atualização de manutenção
	@$(MAKE) update

maintenance-cleanup: ## Limpeza de manutenção
	@$(MAKE) clean

# Comandos de monitoramento
monitor-status: ## Status do monitoramento
	@echo "$(GREEN)Status do monitoramento:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "systemctl status GAME_TYPE-server" --inventory localhost,

monitor-logs: ## Logs do monitoramento
	@$(MAKE) logs

monitor-metrics: ## Métricas do monitoramento
	@echo "$(GREEN)Métricas do monitoramento:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "htop -n 1" --inventory localhost,

# Comandos de segurança
security-check: ## Verificação de segurança
	@echo "$(GREEN)Verificação de segurança:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "ufw status" --inventory localhost,

security-update: ## Atualização de segurança
	@echo "$(GREEN)Atualização de segurança:$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "apt update && apt upgrade -y" --inventory localhost,

# Comandos de backup e restore
backup-full: ## Backup completo
	@$(MAKE) backup

restore-backup: ## Restaura backup
	@echo "$(GREEN)Restaurando backup...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "tar -xzf /home/gameserver/backups/backup-$(BACKUP_DATE).tar.gz -C /" --inventory localhost,

# Comandos de limpeza
clean-logs: ## Limpa logs antigos
	@echo "$(GREEN)Limpando logs antigos...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "find /home/gameserver/logs -name '*.log' -mtime +7 -delete" --inventory localhost,

clean-backups: ## Limpa backups antigos
	@echo "$(GREEN)Limpando backups antigos...$(NC)"
	@cd $(ANSIBLE_DIR) && ansible all -m shell -a "find /home/gameserver/backups -name 'backup-*' -mtime +30 -delete" --inventory localhost,

# Comandos de desenvolvimento
dev-install: ## Instala dependências de desenvolvimento
	@echo "$(GREEN)Instalando dependências de desenvolvimento...$(NC)"
	@pip install ansible-lint
	@pip install terraform-compliance

dev-test: ## Testes de desenvolvimento
	@$(MAKE) test

dev-format: ## Formatação de desenvolvimento
	@$(MAKE) format

# Comandos de documentação
docs-serve: ## Serve documentação localmente
	@echo "$(GREEN)Servindo documentação...$(NC)"
	@cd $(DOCS_DIR) && python3 -m http.server 8080

docs-build: ## Constrói documentação
	@echo "$(GREEN)Construindo documentação...$(NC)"
	@echo "Documentação construída em $(DOCS_DIR)/"

# Comandos de release
release-version: ## Mostra versão atual
	@echo "$(GREEN)Versão atual:$(NC)"
	@git describe --tags --always

release-tag: ## Cria tag de release
	@echo "$(GREEN)Criando tag de release...$(NC)"
	@git tag -a v$(VERSION) -m "Release v$(VERSION)"
	@git push origin v$(VERSION)

# Comandos de ajuda avançada
help-advanced: ## Ajuda avançada
	@echo "$(GREEN)Comandos Avançados:$(NC)"
	@echo "  make GAME_TYPE=sotf deploy-sotf"
	@echo "  make BACKUP_DATE=20240101 restore-backup"
	@echo "  make VERSION=1.0.0 release-tag"

# Comandos de exemplo
example-sotf: ## Exemplo de deploy SotF
	@echo "$(GREEN)Exemplo de deploy Sons of the Forest:$(NC)"
	@echo "  make setup"
	@echo "  make init"
	@echo "  make deploy-sotf"

example-minecraft: ## Exemplo de deploy Minecraft
	@echo "$(GREEN)Exemplo de deploy Minecraft:$(NC)"
	@echo "  make setup"
	@echo "  make init"
	@echo "  make deploy-minecraft"

# Comandos de troubleshooting
troubleshoot-connectivity: ## Troubleshooting de conectividade
	@echo "$(GREEN)Troubleshooting de conectividade:$(NC)"
	@$(MAKE) debug-connectivity

troubleshoot-terraform: ## Troubleshooting do Terraform
	@echo "$(GREEN)Troubleshooting do Terraform:$(NC)"
	@$(MAKE) debug-terraform

troubleshoot-ansible: ## Troubleshooting do Ansible
	@echo "$(GREEN)Troubleshooting do Ansible:$(NC)"
	@$(MAKE) debug-ansible

# Comandos de limpeza completa
clean-all: ## Limpeza completa
	@echo "$(RED)Limpeza completa...$(NC)"
	@$(MAKE) clean
	@$(MAKE) docker-stop
	@$(MAKE) clean-logs
	@$(MAKE) clean-backups

# Comandos de inicialização
init-all: ## Inicialização completa
	@echo "$(GREEN)Inicialização completa...$(NC)"
	@$(MAKE) setup
	@$(MAKE) init
	@$(MAKE) test
	@$(MAKE) docs

# Comandos de finalização
finish: ## Finaliza desenvolvimento
	@echo "$(GREEN)Finalizando desenvolvimento...$(NC)"
	@$(MAKE) clean
	@$(MAKE) docker-stop
	@echo "$(GREEN)Desenvolvimento finalizado!$(NC)"

# Comandos de status
status-all: ## Status completo
	@echo "$(GREEN)Status completo:$(NC)"
	@$(MAKE) status
	@$(MAKE) monitor-status

# Comandos de ajuda final
help-final: ## Ajuda final
	@echo "$(GREEN)Game.Servers - Ajuda Final$(NC)"
	@echo ""
	@echo "Para começar:"
	@echo "  make setup"
	@echo "  make init"
	@echo "  make deploy-sotf"
	@echo ""
	@echo "Para mais ajuda:"
	@echo "  make help"
	@echo "  make list-commands"
	@echo "  make help-advanced"
	@echo ""
	@echo "Documentação: $(DOCS_DIR)/"
	@echo "Contribuição: CONTRIBUTING.md"
	@echo "Changelog: CHANGELOG.md"
