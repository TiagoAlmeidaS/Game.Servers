# Diagrama de Arquitetura - Game.Servers

## Visão Geral do Sistema

```mermaid
graph TB
    subgraph "Desenvolvimento"
        DEV[Desenvolvedor]
        GIT[Git Repository]
        CI[GitHub Actions]
    end
    
    subgraph "Infraestrutura"
        TF[Terraform]
        VPS[VPS/Droplet]
        FW[Firewall]
        DNS[DNS]
    end
    
    subgraph "Configuração"
        ANS[Ansible]
        ROLES[Roles por Jogo]
        PLAY[Playbooks]
    end
    
    subgraph "Jogos Suportados"
        SOTF[Sons of the Forest]
        MC[Minecraft]
        VAL[Valheim]
        RUST[Rust]
        ARK[ARK]
    end
    
    subgraph "Monitoramento"
        LOGS[Logs]
        MON[Monitoramento]
        ALERT[Alertas]
    end
    
    DEV --> GIT
    GIT --> CI
    CI --> TF
    TF --> VPS
    TF --> FW
    TF --> DNS
    TF --> ANS
    ANS --> ROLES
    ROLES --> SOTF
    ROLES --> MC
    ROLES --> VAL
    ROLES --> RUST
    ROLES --> ARK
    VPS --> LOGS
    LOGS --> MON
    MON --> ALERT
```

## Fluxo de Deploy

```mermaid
sequenceDiagram
    participant DEV as Desenvolvedor
    participant GIT as Git
    participant CI as GitHub Actions
    participant TF as Terraform
    participant VPS as VPS
    participant ANS as Ansible
    participant GAME as Servidor de Jogo
    
    DEV->>GIT: git push
    GIT->>CI: Trigger workflow
    CI->>TF: terraform init
    CI->>TF: terraform plan
    CI->>TF: terraform apply
    TF->>VPS: Criar droplet
    TF->>VPS: Configurar firewall
    TF->>ANS: Executar playbook
    ANS->>VPS: Instalar dependências
    ANS->>VPS: Baixar jogo
    ANS->>VPS: Configurar serviço
    ANS->>GAME: Iniciar servidor
    GAME-->>DEV: Servidor pronto
```

## Arquitetura de Módulos

```mermaid
graph LR
    subgraph "Terraform Modules"
        VPS_BASE[vps-base]
        FIREWALL[firewall]
        NETWORKING[networking]
    end
    
    subgraph "Ansible Roles"
        COMMON[common]
        SOTF[sotf]
        MC[minecraft]
        VAL[valheim]
        RUST[rust]
        ARK[ark]
    end
    
    subgraph "Playbooks"
        DEPLOY[deploy-game.yml]
        CLEANUP[cleanup-game.yml]
        UPDATE[update-game.yml]
    end
    
    VPS_BASE --> VPS_BASE
    FIREWALL --> FIREWALL
    NETWORKING --> NETWORKING
    
    COMMON --> SOTF
    COMMON --> MC
    COMMON --> VAL
    COMMON --> RUST
    COMMON --> ARK
    
    DEPLOY --> COMMON
    DEPLOY --> SOTF
    DEPLOY --> MC
    DEPLOY --> VAL
    DEPLOY --> RUST
    DEPLOY --> ARK
```

## Fluxo de Dados

```mermaid
flowchart TD
    START[Início do Deploy]
    CONFIG[Configuração terraform.tfvars]
    INIT[Terraform Init]
    PLAN[Terraform Plan]
    APPLY[Terraform Apply]
    VPS_CREATE[Criar VPS]
    FIREWALL[Configurar Firewall]
    ANSIBLE[Executar Ansible]
    COMMON[Role Common]
    GAME_ROLE[Role do Jogo]
    SERVICE[Configurar Serviço]
    MONITOR[Configurar Monitoramento]
    READY[Servidor Pronto]
    
    START --> CONFIG
    CONFIG --> INIT
    INIT --> PLAN
    PLAN --> APPLY
    APPLY --> VPS_CREATE
    VPS_CREATE --> FIREWALL
    FIREWALL --> ANSIBLE
    ANSIBLE --> COMMON
    COMMON --> GAME_ROLE
    GAME_ROLE --> SERVICE
    SERVICE --> MONITOR
    MONITOR --> READY
```

## Estrutura de Diretórios

```mermaid
graph TD
    ROOT[Game.Servers]
    
    subgraph "Terraform"
        TF_MAIN[main.tf]
        TF_VARS[variables.tf]
        TF_OUT[outputs.tf]
        TF_MODULES[modules/]
        TF_ENV[environments/]
    end
    
    subgraph "Ansible"
        ANS_ROLES[roles/]
        ANS_PLAY[playbooks/]
        ANS_INV[inventory/]
        ANS_CFG[ansible.cfg]
    end
    
    subgraph "Documentação"
        DOCS[docs/]
        README[README.md]
        LICENSE[LICENSE]
    end
    
    subgraph "Scripts"
        SETUP[setup.sh]
        SETUP_PS[setup.ps1]
    end
    
    subgraph "CI/CD"
        GITHUB[.github/workflows/]
    end
    
    ROOT --> TF_MAIN
    ROOT --> TF_VARS
    ROOT --> TF_OUT
    ROOT --> TF_MODULES
    ROOT --> TF_ENV
    ROOT --> ANS_ROLES
    ROOT --> ANS_PLAY
    ROOT --> ANS_INV
    ROOT --> ANS_CFG
    ROOT --> DOCS
    ROOT --> README
    ROOT --> LICENSE
    ROOT --> SETUP
    ROOT --> SETUP_PS
    ROOT --> GITHUB
```

## Monitoramento e Alertas

```mermaid
graph TB
    subgraph "Servidor de Jogo"
        GAME[Processo do Jogo]
        LOGS[Logs do Sistema]
        METRICS[Métricas]
    end
    
    subgraph "Monitoramento"
        MONITOR[Script de Monitoramento]
        CRON[Cron Jobs]
        ALERTS[Sistema de Alertas]
    end
    
    subgraph "Notificações"
        EMAIL[Email]
        SLACK[Slack]
        DISCORD[Discord]
    end
    
    GAME --> LOGS
    GAME --> METRICS
    LOGS --> MONITOR
    METRICS --> MONITOR
    MONITOR --> CRON
    CRON --> ALERTS
    ALERTS --> EMAIL
    ALERTS --> SLACK
    ALERTS --> DISCORD
```

## Escalabilidade

```mermaid
graph TB
    subgraph "Single Server"
        VPS1[VPS 1]
        GAME1[Jogo 1]
    end
    
    subgraph "Multiple Servers"
        VPS2[VPS 2]
        VPS3[VPS 3]
        VPS4[VPS 4]
        GAME2[Jogo 2]
        GAME3[Jogo 3]
        GAME4[Jogo 4]
    end
    
    subgraph "Load Balancing"
        LB[Load Balancer]
        DNS[DNS Round Robin]
    end
    
    subgraph "Auto Scaling"
        AS[Auto Scaling]
        METRICS[Métricas]
        TRIGGER[Triggers]
    end
    
    VPS1 --> GAME1
    VPS2 --> GAME2
    VPS3 --> GAME3
    VPS4 --> GAME4
    
    LB --> VPS2
    LB --> VPS3
    LB --> VPS4
    
    DNS --> LB
    
    METRICS --> TRIGGER
    TRIGGER --> AS
    AS --> VPS2
    AS --> VPS3
    AS --> VPS4
```

## Segurança

```mermaid
graph TB
    subgraph "Acesso"
        SSH[SSH Keys]
        FIREWALL[Firewall Rules]
        VPN[VPN Access]
    end
    
    subgraph "Dados"
        ENCRYPT[Encryption]
        BACKUP[Backup]
        AUDIT[Audit Logs]
    end
    
    subgraph "Aplicação"
        USER[Non-root User]
        PERMS[Permissions]
        UPDATES[Security Updates]
    end
    
    subgraph "Rede"
        SSL[SSL/TLS]
        PROXY[Proxy]
        CDN[CDN]
    end
    
    SSH --> USER
    FIREWALL --> PERMS
    VPN --> SSL
    
    ENCRYPT --> BACKUP
    BACKUP --> AUDIT
    
    USER --> UPDATES
    PERMS --> UPDATES
    
    SSL --> PROXY
    PROXY --> CDN
```

---

**Nota**: Estes diagramas podem ser visualizados usando ferramentas como Mermaid Live Editor ou VS Code com extensão Mermaid.
