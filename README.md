# Game.Servers

Sistema modular de Infrastructure as Code (IaC) para hospedar servidores de jogos diversos como Sons of the Forest, Minecraft, Valheim, Rust, ARK e outros.

## 🎮 Visão Geral

O Game.Servers é uma solução completa de "Game Server as a Service" que permite:

- **Provisionamento automatizado** de servidores VPS
- **Multi-provedor** - funciona com qualquer VPS (DigitalOcean, Hostinger, AWS, Azure, Linode, Vultr)
- **Configuração modular** por tipo de jogo
- **Escalabilidade** para múltiplos servidores
- **Integração web** para criação sob demanda
- **Versionamento** via Git
- **Automação** completa via CI/CD

## 🏗️ Arquitetura

```
Game.Servers/
├── terraform/              # Provisionamento de infraestrutura
│   ├── modules/            # Módulos reutilizáveis
│   ├── environments/       # Configurações por ambiente
│   └── main.tf            # Configuração principal
├── ansible/               # Configuração de servidores
│   ├── roles/             # Roles específicas por jogo
│   └── playbooks/         # Playbooks de deploy
├── web-app/               # Interface web (futuro)
├── docs/                  # Documentação completa
└── .github/workflows/     # CI/CD
```

## 🚀 Jogos Suportados

- ✅ **Sons of the Forest** - Servidor dedicado via SteamCMD
- ✅ **Minecraft** - Servidor Java Edition
- ✅ **Valheim** - Servidor dedicado via SteamCMD
- ✅ **Rust** - Servidor dedicado via SteamCMD
- ✅ **ARK: Survival Evolved** - Servidor dedicado via SteamCMD

## 📋 Pré-requisitos

- Terraform >= 1.5.0
- Ansible >= 2.15.0
- Git
- Conta no provedor de cloud (DigitalOcean, AWS, etc.)
- Chaves SSH configuradas

## 🛠️ Quick Start

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/Game.Servers.git
   cd Game.Servers
   ```

2. **Verificar dependências**
   ```bash
   # Verificar se tudo está instalado
   ./scripts/verify-dependencies.sh
   ```

3. **Configure as variáveis**
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Edite terraform.tfvars com suas credenciais
   ```

4. **Deploy de um servidor**
   ```bash
   # Deploy universal (qualquer provedor)
   ./scripts/deploy-universal.sh digitalocean sotf
   ./scripts/deploy-universal.sh hostinger minecraft
   ./scripts/deploy-universal.sh aws valheim
   
   # Deploy com verificação automática
   ./scripts/deploy-with-verification.sh hostinger sotf prod --monitoring --backup
   
   # Teste específico do Hostinger
   ./scripts/test-hostinger.sh
   
   # Ou deploy manual
   cd terraform
   terraform init
   terraform apply -var="provider=digitalocean" -var="game_type=sotf"
   ```

5. **Acesse seu servidor**
   - IP será exibido no output do Terraform
   - Sons of the Forest: `IP:8766`
   - Minecraft: `IP:25565`
   - Valheim: `IP:2456`
   - Rust: `IP:28015`
   - ARK: `IP:7777`

6. **Verificação automática**
   ```bash
   # Verificar dependências
   ./scripts/verify-dependencies.sh
   
   # Verificar credenciais do provedor
   ./scripts/verify-provider-credentials.sh hostinger
   ```

## 📚 Documentação

Toda documentação está na pasta [`docs/`](./docs/):
- [Setup completo do Sons of the Forest](./docs/sotf-setup.md)
- [Setup completo do Minecraft](./docs/minecraft-setup.md)
- [Setup para Hostinger VPS](./docs/hostinger-setup.md)
- [Setup para AWS](./docs/aws-setup.md)
- [Setup para Azure](./docs/azure-setup.md)
- [Configurações de Jogos](./docs/game-configurations.md)
- [Suporte Multi-Provedor](./docs/multi-provider-setup.md)
- [Arquitetura do sistema](./docs/architecture.md)
- [Guia de expansão para novos jogos](./docs/adding-games.md)
- [Troubleshooting](./docs/troubleshooting.md)

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

- 📖 [Documentação](./docs/)
- 🐛 [Issues](https://github.com/seu-usuario/Game.Servers/issues)
- 💬 [Discussions](https://github.com/seu-usuario/Game.Servers/discussions)