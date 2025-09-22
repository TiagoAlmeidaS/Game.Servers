# Adicionando Novos Jogos ao Game.Servers

Este guia explica como adicionar suporte a novos jogos no sistema Game.Servers, seguindo a arquitetura modular estabelecida.

## 🎮 Visão Geral

Para adicionar um novo jogo ao sistema, você precisa:

1. **Configurar portas** no módulo firewall
2. **Criar role Ansible** específica do jogo
3. **Adicionar validação** no Terraform
4. **Documentar** o novo jogo
5. **Testar** a implementação

## 📋 Checklist de Implementação

- [ ] Adicionar portas no módulo firewall
- [ ] Criar role Ansible específica
- [ ] Atualizar validações do Terraform
- [ ] Adicionar documentação
- [ ] Criar testes
- [ ] Atualizar README

## 🔧 Implementação Passo a Passo

### 1. Configurar Portas no Firewall

Edite `terraform/modules/firewall/main.tf`:

```hcl
locals {
  game_ports = {
    # ... jogos existentes ...
    "novo_jogo" = [
      { port = "25565", protocol = "tcp" },
      { port = "25565", protocol = "udp" }
    ]
  }
}
```

### 2. Criar Role Ansible

Crie a estrutura de diretórios:

```bash
mkdir -p ansible/roles/novo_jogo/{tasks,templates,handlers}
```

#### `ansible/roles/novo_jogo/tasks/main.yml`
```yaml
---
# Role para Novo Jogo

- name: Instalar dependências específicas
  apt:
    name:
      - dependencia1
      - dependencia2
    state: present

- name: Criar diretório do jogo
  file:
    path: /opt/gameservers/novo_jogo
    state: directory
    owner: gameserver
    group: gameserver
    mode: '0755'

- name: Baixar servidor do jogo
  # Implementar download específico
  # Exemplo: wget, curl, steamcmd, etc.

- name: Criar arquivo de configuração
  template:
    src: config.j2
    dest: /opt/gameservers/novo_jogo/config
    owner: gameserver
    group: gameserver
    mode: '0644'

- name: Configurar systemd service
  template:
    src: novo_jogo-server.service.j2
    dest: /etc/systemd/system/novo_jogo-server.service
    mode: '0644'
  notify: restart systemd

- name: Habilitar e iniciar serviço
  systemd:
    name: novo_jogo-server
    enabled: yes
    state: started
    daemon_reload: yes
```

#### `ansible/roles/novo_jogo/templates/config.j2`
```ini
# Configuração do Novo Jogo
server_name={{ server_name }}
max_players={{ max_players }}
port=25565
# ... outras configurações
```

#### `ansible/roles/novo_jogo/templates/novo_jogo-server.service.j2`
```ini
[Unit]
Description=Novo Jogo Dedicated Server
After=network.target
Wants=network.target

[Service]
Type=simple
User=gameserver
Group=gameserver
WorkingDirectory=/opt/gameservers/novo_jogo
ExecStart=/opt/gameservers/novo_jogo/start_server.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=novo_jogo-server

[Install]
WantedBy=multi-user.target
```

### 3. Atualizar Validações do Terraform

Edite `terraform/variables.tf`:

```hcl
variable "game_type" {
  description = "Tipo do jogo (sotf, minecraft, valheim, rust, ark, novo_jogo)"
  type        = string
  validation {
    condition = contains([
      "sotf", "minecraft", "valheim", "rust", "ark", "novo_jogo"
    ], var.game_type)
    error_message = "Tipo de jogo deve ser: sotf, minecraft, valheim, rust, ark ou novo_jogo."
  }
}
```

### 4. Atualizar Playbook Principal

Edite `ansible/playbooks/deploy-game.yml`:

```yaml
- name: Executar role específica do jogo
  include_role:
    name: "{{ game_type }}"
  when: game_type in ['sotf', 'minecraft', 'valheim', 'rust', 'ark', 'novo_jogo']
```

### 5. Adicionar Documentação

Crie `docs/novo_jogo-setup.md`:

```markdown
# Setup do Novo Jogo

## Configuração
- Porta: 25565
- Dependências: dependencia1, dependencia2
- Configuração: config.ini

## Deploy
```bash
terraform apply -var="game_type=novo_jogo"
```

## Troubleshooting
# Adicionar seção de troubleshooting
```

## 🎯 Exemplos Práticos

### Exemplo 1: Minecraft

#### Portas
```hcl
"minecraft" = [
  { port = "25565", protocol = "tcp" },
  { port = "25565", protocol = "udp" }
]
```

#### Role Ansible
```yaml
- name: Instalar Java
  apt:
    name: openjdk-17-jdk
    state: present

- name: Baixar servidor Minecraft
  get_url:
    url: "https://launcher.mojang.com/v1/objects/{{ minecraft_version }}/server.jar"
    dest: /opt/gameservers/minecraft/server.jar
    owner: gameserver
    group: gameserver
    mode: '0644'

- name: Criar server.properties
  template:
    src: server.properties.j2
    dest: /opt/gameservers/minecraft/server.properties
    owner: gameserver
    group: gameserver
    mode: '0644'
```

### Exemplo 2: Valheim

#### Portas
```hcl
"valheim" = [
  { port = "2456", protocol = "tcp" },
  { port = "2456", protocol = "udp" },
  { port = "2457", protocol = "tcp" },
  { port = "2457", protocol = "udp" }
]
```

#### Role Ansible
```yaml
- name: Baixar servidor Valheim via SteamCMD
  shell: |
    steamcmd +login anonymous +app_update 896660 validate +quit
  args:
    chdir: /opt/gameservers/valheim
    creates: /opt/gameservers/valheim/valheim_server.x86_64
  become_user: gameserver
```

## 🧪 Testes

### Teste Manual
```bash
# Deploy do novo jogo
cd terraform
terraform apply -var="game_type=novo_jogo"

# Verificar se o serviço está rodando
ssh root@IP_DO_SERVIDOR
systemctl status novo_jogo-server

# Testar conectividade
telnet IP_DO_SERVIDOR PORTA_DO_JOGO
```

### Teste Automatizado
```yaml
# .github/workflows/test-novo-jogo.yml
name: Test Novo Jogo
on:
  push:
    paths: ['ansible/roles/novo_jogo/**']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Test Ansible Role
        run: |
          cd ansible
          ansible-playbook --check playbooks/deploy-game.yml \
            --extra-vars "game_type=novo_jogo"
```

## 🔍 Validação

### Checklist de Validação
- [ ] Servidor inicia corretamente
- [ ] Portas estão abertas
- [ ] Configuração é aplicada
- [ ] Logs são gerados
- [ ] Serviço reinicia automaticamente
- [ ] Backup funciona
- [ ] Monitoramento funciona

### Comandos de Validação
```bash
# Verificar serviço
systemctl is-active novo_jogo-server

# Verificar portas
netstat -tuln | grep PORTA_DO_JOGO

# Verificar logs
journalctl -u novo_jogo-server -f

# Verificar configuração
cat /opt/gameservers/novo_jogo/config
```

## 📚 Documentação

### Arquivos a Atualizar
- [ ] `README.md` - Lista de jogos suportados
- [ ] `docs/architecture.md` - Arquitetura atualizada
- [ ] `docs/novo_jogo-setup.md` - Documentação específica
- [ ] `terraform/variables.tf` - Validações
- [ ] `ansible/playbooks/deploy-game.yml` - Playbook principal

### Template de Documentação
```markdown
# Novo Jogo - Setup

## Pré-requisitos
- Dependência 1
- Dependência 2

## Configuração
- Porta: XXXX
- Arquivo de config: config.ini
- Dependências: lista

## Deploy
```bash
terraform apply -var="game_type=novo_jogo"
```

## Troubleshooting
### Problema 1
Solução 1

### Problema 2
Solução 2
```

## 🚀 Boas Práticas

### Nomenclatura
- Use nomes em minúsculas
- Use underscores para separar palavras
- Seja consistente com nomes existentes

### Estrutura de Arquivos
```
ansible/roles/novo_jogo/
├── tasks/
│   └── main.yml
├── templates/
│   ├── config.j2
│   └── novo_jogo-server.service.j2
├── handlers/
│   └── main.yml
└── defaults/
    └── main.yml
```

### Variáveis
- Use variáveis para configurações
- Documente todas as variáveis
- Use valores padrão sensatos

### Segurança
- Execute serviços como usuário não-root
- Use permissões mínimas necessárias
- Valide todas as entradas
- Use templates seguros

## 🔄 Manutenção

### Atualizações
- Mantenha dependências atualizadas
- Teste atualizações em ambiente de dev
- Documente mudanças importantes
- Versionamento semântico

### Monitoramento
- Adicione métricas específicas do jogo
- Configure alertas apropriados
- Monitore logs de erro
- Acompanhe performance

## 🆘 Suporte

### Recursos
- Documentação oficial do jogo
- Fóruns da comunidade
- Issues do GitHub
- Discord/Slack da equipe

### Contato
- GitHub Issues
- Email da equipe
- Discord/Slack
- Fórum da comunidade

---

**Nota**: Este guia é um template. Adapte conforme necessário para cada jogo específico.
