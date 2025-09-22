# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Adicionado
- Suporte inicial para Sons of the Forest
- Suporte inicial para Minecraft
- Estrutura modular com Terraform e Ansible
- Documentação completa
- Scripts de setup para Linux e Windows
- CI/CD com GitHub Actions
- Monitoramento básico
- Sistema de backup automático

### Planejado
- Suporte para Valheim
- Suporte para Rust
- Suporte para ARK: Survival Evolved
- Interface web para gerenciamento
- API REST para automação
- Métricas avançadas com Prometheus
- Alertas via Slack/Discord
- Suporte multi-cloud (AWS, Azure)
- Deploy em Kubernetes
- Auto-scaling
- CDN para distribuição global

## [1.0.0] - 2024-01-XX

### Adicionado
- **Terraform Modules**
  - Módulo `vps-base` para provisionamento genérico de VPS
  - Módulo `firewall` com regras específicas por jogo
  - Suporte a múltiplos ambientes (dev, staging, prod)
  - Configurações por ambiente via arquivos .tfvars

- **Ansible Roles**
  - Role `common` com configurações básicas
  - Role `sotf` para Sons of the Forest
  - Role `minecraft` para Minecraft
  - Playbooks de deploy, cleanup e update
  - Templates para configurações de jogos

- **Jogos Suportados**
  - Sons of the Forest (porta 8766)
  - Minecraft (porta 25565)
  - Estrutura preparada para Valheim, Rust e ARK

- **Documentação**
  - README completo com quick start
  - Guias de setup específicos por jogo
  - Documentação de arquitetura
  - Guia para adicionar novos jogos
  - Troubleshooting detalhado

- **Scripts e Automação**
  - Script de setup para Linux (`setup.sh`)
  - Script de setup para Windows (`setup.ps1`)
  - GitHub Actions para CI/CD
  - Validação automática de código

- **Monitoramento**
  - Script de monitoramento básico
  - Logs centralizados
  - Métricas de CPU, RAM e disco
  - Verificação de conectividade

- **Segurança**
  - Usuário não-root para serviços
  - Firewall configurado por jogo
  - Permissões mínimas necessárias
  - Backup automático de saves

### Características Técnicas
- **Terraform**: >= 1.5.0
- **Ansible**: >= 2.15.0
- **Provedor**: DigitalOcean
- **OS**: Ubuntu 22.04 LTS
- **Arquitetura**: Modular e escalável
- **Versionamento**: Git com tags semânticas

### Configurações Suportadas
- **Regiões**: nyc1, nyc3, sfo3, sgp1, fra1, etc.
- **Tamanhos**: s-1vcpu-2gb até s-4vcpu-8gb
- **Ambientes**: dev, staging, prod
- **Jogos**: Sons of the Forest, Minecraft

## [0.9.0] - 2024-01-XX (Beta)

### Adicionado
- Estrutura base do projeto
- Módulos Terraform básicos
- Roles Ansible iniciais
- Documentação inicial
- Scripts de setup

### Mudanças
- Primeira versão beta
- Testes iniciais com Sons of the Forest
- Validação da arquitetura modular

## [0.8.0] - 2024-01-XX (Alpha)

### Adicionado
- Conceito inicial do projeto
- Estrutura de diretórios
- Configurações básicas do Terraform
- Primeiros testes com Ansible

### Mudanças
- Versão alpha para validação de conceito
- Testes com provedores de cloud
- Definição da arquitetura

---

## Como Contribuir

Para contribuir com este projeto:

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Versionamento

Este projeto usa [Versionamento Semântico](https://semver.org/lang/pt-BR/):

- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Funcionalidades adicionadas de forma compatível
- **PATCH**: Correções de bugs compatíveis

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

**Nota**: Este changelog é mantido manualmente. Para mudanças automáticas, consulte os commits do Git.
