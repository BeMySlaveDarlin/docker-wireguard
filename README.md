# WireGuard VPN Docker Project

WireGuard VPN сервер с Docker + WSL клиент для туннельного соединения.

## Быстрый старт

### VPS сервер:
```bash
make all                    # Запустить VPN сервер
make show-peer peer=1       # Получить конфиг для peer 1
make show-peer peer=2       # Получить конфиг для peer 2
```

### WSL клиент:
```bash
# Управление локальными сервисами
make restart-wsl            # Перезапуск WireGuard + SSH
make status-wsl             # Статус сервисов
make start-wsl              # Запуск сервисов
make stop-wsl               # Остановка сервисов
make help                   # Показать все команды
```

## Конфигурация

**VPN настройки:**
- Сервер: `135.181.109.14:51820`
- Подсеть: `10.13.13.0/24`
- Режим: только туннель (интернет через Outline)

**SSH доступ:**
- IP: `10.13.13.2:22`
- Пользователь: `root`
- Аутентификация: SSH ключи

## Файлы проекта

- `restart-services.sh` - Скрипт перезапуска WireGuard + SSH
- `config/wireguard/peer1/` - Конфиг для WSL
- `config/wireguard/peer2/` - Конфиг для телефона
- `/root/.ssh/termius_key` - SSH ключ для Termius

## Автозапуск

Настроен через cron:
- WireGuard туннель: автоматически при старте WSL
- SSH сервер: автоматически при старте WSL

## Troubleshooting

```bash
# Проверка статуса
make status-wsl

# Перезапуск если проблемы
make restart-wsl

# Проверка подключения к VPS
ping 10.13.13.1

# Проверка SSH
netstat -tlnp | grep :22
```