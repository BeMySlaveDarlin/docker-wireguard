#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== WireGuard и SSH перезапуск ===${NC}"
echo ""

# Функция для красивого вывода статуса
print_status() {
    local service=$1
    local status=$2
    if [ "$status" = "OK" ]; then
        echo -e "${service}: ${GREEN}${status}${NC}"
    else
        echo -e "${service}: ${RED}${status}${NC}"
    fi
}

# Остановка WireGuard
echo -e "${YELLOW}Остановка WireGuard туннеля...${NC}"
sudo wg-quick down tunnel 2>/dev/null
if [ $? -eq 0 ]; then
    print_status "WireGuard stop" "OK"
else
    print_status "WireGuard stop" "ALREADY DOWN"
fi

# Остановка SSH
echo -e "${YELLOW}Остановка SSH сервера...${NC}"
SSH_PID=$(pgrep -f "sshd.*listener")
if [ -n "$SSH_PID" ]; then
    sudo kill $SSH_PID 2>/dev/null
    sleep 1
    print_status "SSH stop" "OK"
else
    print_status "SSH stop" "NOT RUNNING"
fi

echo ""
echo -e "${YELLOW}Запуск сервисов...${NC}"

# Создание директории для SSH если нужно
sudo mkdir -p /run/sshd

# Запуск WireGuard
echo -e "${YELLOW}Запуск WireGuard туннеля...${NC}"
sudo wg-quick up tunnel
if [ $? -eq 0 ]; then
    print_status "WireGuard start" "OK"
else
    print_status "WireGuard start" "ERROR"
    echo -e "${RED}Ошибка запуска WireGuard! Проверьте конфигурацию.${NC}"
fi

# Запуск SSH
echo -e "${YELLOW}Запуск SSH сервера...${NC}"
sudo /usr/sbin/sshd
if [ $? -eq 0 ]; then
    print_status "SSH start" "OK"
else
    print_status "SSH start" "ERROR"
    echo -e "${RED}Ошибка запуска SSH! Проверьте конфигурацию.${NC}"
fi

echo ""
echo -e "${BLUE}=== Статус сервисов ===${NC}"

# Проверка WireGuard
WG_STATUS=$(wg show 2>/dev/null)
if [ -n "$WG_STATUS" ]; then
    print_status "WireGuard" "ACTIVE"
    echo -e "${GREEN}Туннель IP: $(ip addr show tunnel 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)${NC}"
else
    print_status "WireGuard" "INACTIVE"
fi

# Проверка SSH
SSH_STATUS=$(netstat -tlnp 2>/dev/null | grep ':22 ')
if [ -n "$SSH_STATUS" ]; then
    print_status "SSH" "LISTENING on port 22"
else
    print_status "SSH" "NOT LISTENING"
fi

# Проверка подключения к серверу WireGuard
echo ""
echo -e "${YELLOW}Проверка подключения к VPS...${NC}"
if ping -c 1 -W 2 10.13.13.1 >/dev/null 2>&1; then
    print_status "VPS connection" "OK (10.13.13.1)"
else
    print_status "VPS connection" "FAILED"
fi

echo ""
echo -e "${GREEN}Готово! Туннель готов к SSH подключению: ${BLUE}root@10.13.13.2:22${NC}"