# Configurações de Jogos - Game.Servers

Este guia detalha como configurar cada jogo suportado pelo Game.Servers, incluindo variáveis, templates e configurações específicas.

## 🎮 Jogos Suportados

### ✅ **Implementados Completamente**
- **Sons of the Forest** - Servidor dedicado via SteamCMD
- **Minecraft** - Servidor Java Edition
- **Valheim** - Servidor dedicado via SteamCMD
- **Rust** - Servidor dedicado via SteamCMD
- **ARK: Survival Evolved** - Servidor dedicado via SteamCMD

## 📋 Estrutura de Configuração

Cada jogo segue a mesma estrutura modular:

```
ansible/roles/[jogo]/
├── tasks/main.yml           # Tarefas principais
├── templates/               # Templates de configuração
│   ├── config.j2           # Arquivo de configuração
│   ├── start_server.sh.j2  # Script de inicialização
│   └── [jogo]-server.service.j2  # Serviço systemd
├── defaults/main.yml        # Variáveis padrão
└── handlers/main.yml        # Handlers (opcional)
```

## 🎯 Sons of the Forest (SotF)

### **Configuração Básica**
```hcl
# terraform.tfvars
game_type = "sotf"
server_name = "MeuServidorSotF"
server_password = "minha-senha-segura"
max_players = 8
```

### **Variáveis Disponíveis**
```yaml
# ansible/roles/sotf/defaults/main.yml
sotf_server_name: "{{ server_name }}"
sotf_server_password: "{{ server_password }}"
sotf_max_players: 8
sotf_difficulty: "Normal"
sotf_port: 8766
sotf_save_interval: 300
sotf_enable_vac: true
sotf_enable_cheats: false
sotf_enable_mods: true
sotf_enable_pvp: true
sotf_enable_friendly_fire: false
```

### **Portas Necessárias**
- **8766/TCP** - Conexão principal
- **8766/UDP** - Dados do jogo

### **Recursos Recomendados**
- **RAM**: 8GB mínimo
- **CPU**: 2 vCPU mínimo
- **Disco**: 20GB mínimo

## 🧱 Minecraft

### **Configuração Básica**
```hcl
# terraform.tfvars
game_type = "minecraft"
server_name = "MeuServidorMinecraft"
max_players = 20
minecraft_difficulty = "normal"
minecraft_gamemode = "survival"
```

### **Variáveis Disponíveis**
```yaml
# ansible/roles/minecraft/defaults/main.yml
minecraft_version: "a1ffa95deebd449c644a6cdd3cdd832c0a8dd4ff"
minecraft_difficulty: "normal"
minecraft_gamemode: "survival"
minecraft_hardcore: false
minecraft_pvp: true
minecraft_level_type: "minecraft:normal"
minecraft_seed: ""
minecraft_structures: true
minecraft_online_mode: true
minecraft_whitelist: false
minecraft_view_distance: 10
minecraft_simulation_distance: 10
minecraft_max_tick_time: 60000
minecraft_spawn_protection: 16
minecraft_java_opts: "-Xmx3G -Xms2G"
```

### **Portas Necessárias**
- **25565/TCP** - Conexão principal

### **Recursos Recomendados**
- **RAM**: 4GB mínimo (2GB para servidor + 2GB para Java)
- **CPU**: 2 vCPU mínimo
- **Disco**: 10GB mínimo

## ⚔️ Valheim (Em Desenvolvimento)

### **Configuração Planejada**
```hcl
# terraform.tfvars
game_type = "valheim"
server_name = "MeuServidorValheim"
server_password = "minha-senha-segura"
max_players = 10
valheim_world_name = "Dedicated"
valheim_public = true
```

### **Variáveis Planejadas**
```yaml
# ansible/roles/valheim/defaults/main.yml
valheim_server_name: "{{ server_name }}"
valheim_server_password: "{{ server_password }}"
valheim_max_players: 10
valheim_world_name: "Dedicated"
valheim_public: true
valheim_port: 2456
valheim_query_port: 2457
valheim_steam_port: 2458
```

### **Portas Necessárias**
- **2456/UDP** - Conexão principal
- **2457/UDP** - Query port
- **2458/UDP** - Steam port

### **Recursos Recomendados**
- **RAM**: 4GB mínimo
- **CPU**: 2 vCPU mínimo
- **Disco**: 15GB mínimo

## 🔫 Rust (Em Desenvolvimento)

### **Configuração Planejada**
```hcl
# terraform.tfvars
game_type = "rust"
server_name = "MeuServidorRust"
server_description = "Servidor Rust - Game.Servers"
max_players = 50
rust_world_size = 4000
rust_seed = 12345
```

### **Variáveis Planejadas**
```yaml
# ansible/roles/rust/defaults/main.yml
rust_server_name: "{{ server_name }}"
rust_server_description: "{{ server_description }}"
rust_max_players: 50
rust_world_size: 4000
rust_seed: 12345
rust_port: 28015
rust_query_port: 28016
rust_rcon_port: 28017
rust_rcon_password: "{{ server_password }}"
rust_oxide: true
rust_umod: true
```

### **Portas Necessárias**
- **28015/TCP** - Conexão principal
- **28015/UDP** - Dados do jogo
- **28016/TCP** - Query port
- **28017/TCP** - RCON port

### **Recursos Recomendados**
- **RAM**: 8GB mínimo
- **CPU**: 4 vCPU mínimo
- **Disco**: 25GB mínimo

## 🦕 ARK: Survival Evolved (Em Desenvolvimento)

### **Configuração Planejada**
```hcl
# terraform.tfvars
game_type = "ark"
server_name = "MeuServidorARK"
server_password = "minha-senha-segura"
max_players = 20
ark_map = "TheIsland"
ark_difficulty = 1.0
ark_harvest_multiplier = 2.0
```

### **Variáveis Planejadas**
```yaml
# ansible/roles/ark/defaults/main.yml
ark_server_name: "{{ server_name }}"
ark_server_password: "{{ server_password }}"
ark_max_players: 20
ark_map: "TheIsland"
ark_difficulty: 1.0
ark_harvest_multiplier: 2.0
ark_taming_multiplier: 2.0
ark_xp_multiplier: 2.0
ark_port: 7777
ark_query_port: 27015
ark_rcon_port: 32330
ark_rcon_password: "{{ server_password }}"
```

### **Portas Necessárias**
- **7777/UDP** - Conexão principal
- **27015/UDP** - Query port
- **32330/TCP** - RCON port

### **Recursos Recomendados**
- **RAM**: 16GB mínimo
- **CPU**: 4 vCPU mínimo
- **Disco**: 50GB mínimo

## 🔧 Configuração Avançada

### **Variáveis Globais**
```yaml
# ansible/group_vars/all.yml
# Configurações comuns para todos os jogos
server_timezone: "UTC"
server_restart_schedule: "0 4 * * *"  # 4h da manhã
server_backup_schedule: "0 2 * * *"   # 2h da manhã
server_log_retention_days: 30
server_monitoring_enabled: true
server_alerts_enabled: true
```

### **Configuração por Ambiente**
```yaml
# ansible/group_vars/dev.yml
server_restart_schedule: "0 2 * * *"  # Mais frequente em dev
server_backup_schedule: "0 1 * * *"
server_log_retention_days: 7

# ansible/group_vars/prod.yml
server_restart_schedule: "0 4 * * *"  # Menos frequente em prod
server_backup_schedule: "0 2 * * *"
server_log_retention_days: 90
```

## 📊 Monitoramento por Jogo

### **Métricas Específicas**
```yaml
# Sons of the Forest
sotf_metrics:
  - players_online
  - server_uptime
  - memory_usage
  - cpu_usage

# Minecraft
minecraft_metrics:
  - players_online
  - tps (ticks per second)
  - memory_usage
  - chunk_loading

# Valheim
valheim_metrics:
  - players_online
  - world_size
  - memory_usage
  - cpu_usage
```

## 🚀 Deploy por Jogo

### **Comandos de Deploy**
```bash
# Sons of the Forest
./scripts/deploy-universal.sh aws sotf prod

# Minecraft
./scripts/deploy-universal.sh hostinger minecraft prod

# Valheim (quando implementado)
./scripts/deploy-universal.sh azure valheim prod

# Rust (quando implementado)
./scripts/deploy-universal.sh linode rust prod

# ARK (quando implementado)
./scripts/deploy-universal.sh vultr ark prod
```

### **Deploy com Configurações Customizadas**
```bash
# Deploy com configurações específicas
terraform apply \
  -var="game_type=sotf" \
  -var="server_name=MeuServidor" \
  -var="max_players=16" \
  -var="sotf_difficulty=Hard"
```

## 🔍 Troubleshooting por Jogo

### **Sons of the Forest**
```bash
# Verificar logs
journalctl -u sotf-server -f

# Verificar configuração
cat /opt/gameservers/sotf/dedicatedserver.cfg

# Reiniciar serviço
systemctl restart sotf-server
```

### **Minecraft**
```bash
# Verificar logs
journalctl -u minecraft-server -f

# Verificar configuração
cat /opt/gameservers/minecraft/server.properties

# Reiniciar serviço
systemctl restart minecraft-server
```

## 📚 Próximos Passos

### **Para Implementar Novos Jogos:**
1. **Criar role Ansible** específica
2. **Configurar portas** no firewall
3. **Adicionar variáveis** no Terraform
4. **Criar templates** de configuração
5. **Testar** a implementação
6. **Documentar** o novo jogo

### **Para Customizar Jogos Existentes:**
1. **Editar variáveis** em `defaults/main.yml`
2. **Modificar templates** em `templates/`
3. **Ajustar recursos** no Terraform
4. **Testar** as mudanças
5. **Deploy** em produção

---

**Nota**: Este guia é atualizado conforme novos jogos são implementados. Para jogos em desenvolvimento, as configurações são planejadas e podem mudar durante a implementação.
