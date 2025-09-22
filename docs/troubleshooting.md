# Troubleshooting - Game.Servers

Este guia ajuda a resolver problemas comuns no Game.Servers.

## 🔍 Problemas Gerais

### Terraform não inicializa
```bash
# Erro: Provider not found
terraform init

# Solução: Verificar versão do Terraform
terraform version
# Deve ser >= 1.5.0
```

### Ansible não conecta
```bash
# Erro: SSH connection failed
# Verificar chave SSH
ssh-add -l

# Testar conexão manual
ssh -i ~/.ssh/id_rsa root@IP_DO_SERVIDOR
```

### Servidor não inicia
```bash
# Verificar logs do systemd
journalctl -u GAME_TYPE-server -f

# Verificar status
systemctl status GAME_TYPE-server

# Reiniciar serviço
systemctl restart GAME_TYPE-server
```

## 🎮 Sons of the Forest

### Servidor não baixa via SteamCMD
```bash
# Verificar se SteamCMD está instalado
which steamcmd

# Instalar manualmente
apt-get update
apt-get install steamcmd

# Baixar manualmente
steamcmd +login anonymous +app_update 2465200 validate +quit
```

### Porta 8766 não acessível
```bash
# Verificar firewall
ufw status

# Abrir porta manualmente
ufw allow 8766/tcp
ufw allow 8766/udp

# Verificar se o serviço está rodando
netstat -tuln | grep 8766
```

### Configuração não aplicada
```bash
# Verificar arquivo de configuração
cat /opt/gameservers/sotf/dedicatedserver.cfg

# Recriar configuração
ansible-playbook -i IP_DO_SERVIDOR, playbooks/deploy-game.yml --extra-vars "game_type=sotf"
```

## 🧱 Minecraft

### Java não encontrado
```bash
# Instalar Java 17
apt-get update
apt-get install openjdk-17-jdk

# Verificar instalação
java -version
```

### Servidor não inicia
```bash
# Verificar logs
journalctl -u minecraft-server -f

# Verificar arquivo eula.txt
cat /opt/gameservers/minecraft/eula.txt
# Deve conter: eula=true

# Verificar server.properties
cat /opt/gameservers/minecraft/server.properties
```

### Problemas de memória
```bash
# Verificar uso de memória
free -h

# Ajustar configurações de Java
# Editar /opt/gameservers/minecraft/start_server.sh
# Alterar -Xmx2G para -Xmx4G
```

### Porta 25565 não acessível
```bash
# Verificar firewall
ufw status

# Abrir porta
ufw allow 25565/tcp
ufw allow 25565/udp

# Verificar se o servidor está rodando
netstat -tuln | grep 25565
```

## 🔧 Problemas de Infraestrutura

### VPS não cria
```bash
# Verificar credenciais
echo $TF_VAR_do_token

# Verificar região
terraform plan -var="region=nyc3"

# Verificar tamanho da instância
terraform plan -var="instance_size=s-1vcpu-2gb"
```

### Firewall não aplica
```bash
# Verificar regras do DigitalOcean
doctl compute firewall list

# Verificar regras locais
ufw status verbose

# Recriar firewall
terraform apply -target=module.firewall
```

### DNS não resolve
```bash
# Verificar DNS
nslookup google.com

# Configurar DNS manualmente
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
```

## 📊 Problemas de Monitoramento

### Logs não aparecem
```bash
# Verificar permissões
ls -la /home/gameserver/logs/

# Corrigir permissões
chown -R gameserver:gameserver /home/gameserver/logs/

# Verificar logrotate
logrotate -d /etc/logrotate.d/gameserver
```

### Monitoramento não funciona
```bash
# Verificar script de monitoramento
cat /home/gameserver/monitor.sh

# Executar manualmente
/home/gameserver/monitor.sh

# Verificar cron
crontab -u gameserver -l
```

### Alertas não enviam
```bash
# Verificar configuração de email
which mail

# Instalar mailutils
apt-get install mailutils

# Testar envio
echo "Teste" | mail -s "Teste" seu-email@exemplo.com
```

## 🔄 Problemas de Atualização

### Terraform não atualiza
```bash
# Limpar cache
rm -rf .terraform/
terraform init

# Atualizar providers
terraform init -upgrade
```

### Ansible não atualiza
```bash
# Atualizar via pip
pip install --upgrade ansible

# Verificar versão
ansible --version
```

### Servidor não atualiza
```bash
# Forçar atualização
ansible-playbook -i IP_DO_SERVIDOR, playbooks/deploy-game.yml --extra-vars "game_type=TIPO" --force

# Limpar cache do Ansible
rm -rf ~/.ansible/
```

## 🗑️ Problemas de Limpeza

### Terraform não destrói
```bash
# Destruir recursos específicos
terraform destroy -target=module.vps_base

# Forçar destruição
terraform destroy -auto-approve

# Limpar estado
terraform state list
terraform state rm RECURSO
```

### Ansible não limpa
```bash
# Executar cleanup manual
ansible-playbook -i IP_DO_SERVIDOR, playbooks/cleanup-game.yml --extra-vars "game_type=TIPO"

# Limpar manualmente
ssh root@IP_DO_SERVIDOR
systemctl stop GAME_TYPE-server
rm -rf /opt/gameservers/GAME_TYPE/
```

## 🔐 Problemas de Segurança

### SSH não conecta
```bash
# Verificar chave SSH
ssh-keygen -l -f ~/.ssh/id_rsa.pub

# Regenerar chave
ssh-keygen -t rsa -b 4096 -C "seu-email@exemplo.com"

# Adicionar ao DigitalOcean
doctl compute ssh-key import nome-da-chave --public-key-file ~/.ssh/id_rsa.pub
```

### Permissões incorretas
```bash
# Corrigir permissões do usuário
chown -R gameserver:gameserver /opt/gameservers/
chown -R gameserver:gameserver /home/gameserver/

# Corrigir permissões de arquivos
chmod 755 /opt/gameservers/
chmod 644 /opt/gameservers/*/config*
```

### Firewall bloqueia tudo
```bash
# Resetar firewall
ufw --force reset

# Configurar regras básicas
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 22
ufw allow PORTA_DO_JOGO
ufw enable
```

## 📈 Problemas de Performance

### Servidor lento
```bash
# Verificar recursos
htop
df -h
free -h

# Verificar processos
ps aux | grep GAME_TYPE

# Verificar logs de erro
journalctl -u GAME_TYPE-server | grep -i error
```

### Alto uso de CPU
```bash
# Verificar processos
top -p $(pgrep GAME_TYPE)

# Verificar configurações
cat /opt/gameservers/GAME_TYPE/config*

# Ajustar configurações de performance
```

### Alto uso de memória
```bash
# Verificar uso de memória
free -h
cat /proc/meminfo

# Verificar swap
swapon -s

# Ajustar configurações de memória
```

## 🆘 Suporte Avançado

### Logs detalhados
```bash
# Ativar debug do Ansible
ansible-playbook -vvv playbooks/deploy-game.yml

# Ativar debug do Terraform
export TF_LOG=DEBUG
terraform apply

# Logs do systemd
journalctl -u GAME_TYPE-server -f --no-pager
```

### Backup de emergência
```bash
# Fazer backup completo
tar -czf backup-$(date +%Y%m%d).tar.gz /opt/gameservers/ /home/gameserver/

# Backup apenas do mundo/saves
tar -czf saves-$(date +%Y%m%d).tar.gz /opt/gameservers/GAME_TYPE/saves/
```

### Restauração
```bash
# Restaurar backup
tar -xzf backup-YYYYMMDD.tar.gz -C /

# Restaurar apenas saves
tar -xzf saves-YYYYMMDD.tar.gz -C /opt/gameservers/GAME_TYPE/
```

## 📞 Contato

### Recursos de Suporte
- **GitHub Issues**: [Link para issues]
- **Discord**: [Link para Discord]
- **Email**: [Seu email]
- **Documentação**: [docs/](./)

### Informações para Suporte
Ao solicitar suporte, inclua:
- Versão do Terraform: `terraform version`
- Versão do Ansible: `ansible --version`
- Logs de erro: `journalctl -u GAME_TYPE-server`
- Configuração: `terraform show`
- Sistema operacional: `uname -a`

---

**Nota**: Este guia cobre os problemas mais comuns. Para problemas específicos, consulte a documentação do jogo ou abra uma issue no GitHub.
