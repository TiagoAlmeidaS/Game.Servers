#!/bin/bash
# Script de verificação de deploy do servidor

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Verificação de Deploy${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar parâmetros
if [ $# -lt 3 ]; then
    print_error "Uso: $0 <server_ip> <game_type> <ssh_key_path>"
    echo ""
    echo "Exemplo: $0 192.168.1.100 sotf ~/.ssh/id_rsa"
    exit 1
fi

SERVER_IP=$1
GAME_TYPE=$2
SSH_KEY_PATH=$3

print_header
print_message "🔍 Verificando servidor $GAME_TYPE em $SERVER_IP..."

# Verificar se a chave SSH existe
if [ ! -f "$SSH_KEY_PATH" ]; then
    print_error "❌ Chave SSH não encontrada: $SSH_KEY_PATH"
    exit 1
fi

# Aguardar servidor ficar disponível
print_message "⏳ Aguardando servidor ficar disponível..."
MAX_ATTEMPTS=30
ATTEMPT=1

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@"$SERVER_IP" "echo 'Servidor disponível'" > /dev/null 2>&1; then
        print_message "✅ Servidor disponível (tentativa $ATTEMPT/$MAX_ATTEMPTS)"
        break
    fi
    
    if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
        print_error "❌ Servidor não ficou disponível após $MAX_ATTEMPTS tentativas"
        exit 1
    fi
    
    print_message "Tentativa $ATTEMPT/$MAX_ATTEMPTS - aguardando 10 segundos..."
    sleep 10
    ATTEMPT=$((ATTEMPT + 1))
done

# Verificar se o serviço do jogo está rodando
print_message "🔍 Verificando serviço do jogo..."
case $GAME_TYPE in
  "sotf")
    if ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "systemctl is-active sotf-server" | grep -q "active"; then
        print_message "✅ Serviço Sons of the Forest ativo"
    else
        print_error "❌ Serviço Sons of the Forest inativo"
        print_message "Logs do serviço:"
        ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl -u sotf-server --no-pager -n 20"
        exit 1
    fi
    ;;
  "minecraft")
    if ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "systemctl is-active minecraft-server" | grep -q "active"; then
        print_message "✅ Serviço Minecraft ativo"
    else
        print_error "❌ Serviço Minecraft inativo"
        print_message "Logs do serviço:"
        ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl -u minecraft-server --no-pager -n 20"
        exit 1
    fi
    ;;
  "valheim")
    if ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "systemctl is-active valheim-server" | grep -q "active"; then
        print_message "✅ Serviço Valheim ativo"
    else
        print_error "❌ Serviço Valheim inativo"
        print_message "Logs do serviço:"
        ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl -u valheim-server --no-pager -n 20"
        exit 1
    fi
    ;;
  "rust")
    if ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "systemctl is-active rust-server" | grep -q "active"; then
        print_message "✅ Serviço Rust ativo"
    else
        print_error "❌ Serviço Rust inativo"
        print_message "Logs do serviço:"
        ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl -u rust-server --no-pager -n 20"
        exit 1
    fi
    ;;
  "ark")
    if ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "systemctl is-active ark-server" | grep -q "active"; then
        print_message "✅ Serviço ARK ativo"
    else
        print_error "❌ Serviço ARK inativo"
        print_message "Logs do serviço:"
        ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl -u ark-server --no-pager -n 20"
        exit 1
    fi
    ;;
  *)
    print_error "❌ Tipo de jogo '$GAME_TYPE' não suportado"
    exit 1
    ;;
esac

# Verificar portas
print_message "🔍 Verificando portas..."
case $GAME_TYPE in
  "sotf")
    if command -v nc &> /dev/null; then
        if nc -z "$SERVER_IP" 8766; then
            print_message "✅ Porta 8766 (Sons of the Forest) aberta"
        else
            print_error "❌ Porta 8766 (Sons of the Forest) fechada"
            exit 1
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
    ;;
  "minecraft")
    if command -v nc &> /dev/null; then
        if nc -z "$SERVER_IP" 25565; then
            print_message "✅ Porta 25565 (Minecraft) aberta"
        else
            print_error "❌ Porta 25565 (Minecraft) fechada"
            exit 1
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
    ;;
  "valheim")
    if command -v nc &> /dev/null; then
        if nc -z "$SERVER_IP" 2456; then
            print_message "✅ Porta 2456 (Valheim) aberta"
        else
            print_error "❌ Porta 2456 (Valheim) fechada"
            exit 1
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
    ;;
  "rust")
    if command -v nc &> /dev/null; then
        if nc -z "$SERVER_IP" 28015; then
            print_message "✅ Porta 28015 (Rust) aberta"
        else
            print_error "❌ Porta 28015 (Rust) fechada"
            exit 1
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
    ;;
  "ark")
    if command -v nc &> /dev/null; then
        if nc -z "$SERVER_IP" 7777; then
            print_message "✅ Porta 7777 (ARK) aberta"
        else
            print_error "❌ Porta 7777 (ARK) fechada"
            exit 1
        fi
    else
        print_warning "⚠️ netcat não disponível, não é possível verificar portas"
    fi
    ;;
esac

# Verificar recursos do sistema
print_message "🔍 Verificando recursos do sistema..."
CPU_USAGE=$(ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1" 2>/dev/null || echo "N/A")
MEMORY_USAGE=$(ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "free | grep Mem | awk '{printf \"%.1f\", \$3/\$2 * 100.0}'" 2>/dev/null || echo "N/A")
DISK_USAGE=$(ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "df -h / | awk 'NR==2{print \$5}' | cut -d'%' -f1" 2>/dev/null || echo "N/A")

print_message "📊 Recursos do sistema:"
print_message "  CPU: ${CPU_USAGE}%"
print_message "  Memória: ${MEMORY_USAGE}%"
print_message "  Disco: ${DISK_USAGE}%"

# Verificar logs de erro
print_message "🔍 Verificando logs de erro..."
ERROR_COUNT=$(ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl --since '5 minutes ago' --priority=err --no-pager | wc -l" 2>/dev/null || echo "0")

if [ "$ERROR_COUNT" -gt 0 ]; then
    print_warning "⚠️ $ERROR_COUNT erros encontrados nos últimos 5 minutos"
    print_message "Logs de erro:"
    ssh -i "$SSH_KEY_PATH" root@"$SERVER_IP" "journalctl --since '5 minutes ago' --priority=err --no-pager -n 10"
else
    print_message "✅ Nenhum erro encontrado nos logs"
fi

# Verificar conectividade de rede
print_message "🔍 Verificando conectividade de rede..."
if ping -c 3 "$SERVER_IP" > /dev/null 2>&1; then
    print_message "✅ Conectividade de rede OK"
else
    print_warning "⚠️ Problemas de conectividade de rede"
fi

print_message "🎉 Servidor $GAME_TYPE verificado com sucesso!"
print_message "📋 Resumo:"
print_message "  IP: $SERVER_IP"
print_message "  Jogo: $GAME_TYPE"
print_message "  Status: Ativo e funcionando"
print_message "  Recursos: CPU ${CPU_USAGE}%, Memória ${MEMORY_USAGE}%, Disco ${DISK_USAGE}%"
