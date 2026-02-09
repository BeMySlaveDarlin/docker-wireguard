all: build start

help:
	@echo "WireGuard VPN Management Commands:"
	@echo ""
	@echo "Docker VPN Server:"
	@echo "  all          - Build and start VPN server"
	@echo "  build        - Build docker image"
	@echo "  start        - Start VPN server"
	@echo "  down         - Stop VPN server"
	@echo "  restart      - Restart VPN server"
	@echo "  show-peer    - Show peer config (use: make show-peer peer=1)"
	@echo "  show-stat    - Show server statistics"
	@echo ""
	@echo "WSL Client Services:"
	@echo "  restart-wsl  - Restart WireGuard + SSH on WSL"
	@echo "  status-wsl   - Show WSL services status"
	@echo "  start-wsl    - Start WSL services"
	@echo "  stop-wsl     - Stop WSL services"
	@echo ""
	@echo "Usage examples:"
	@echo "  make all                    # Start VPN server"
	@echo "  make show-peer peer=1       # Get config for peer 1"
	@echo "  make restart-wsl            # Restart WSL services"
	@echo "  make status-wsl             # Check connection status"

build:
	@docker compose build

start:
	@docker compose up -d

down:
	@docker compose down

restart: down start

show-peer:
	@docker exec -it wireguard /app/show-peer $(peer)

show-stat:
	@docker exec -it wireguard wg

# WSL local services management
restart-wsl:
	@./restart-services.sh

status-wsl:
	@echo "=== WireGuard Status ==="
	@wg show 2>/dev/null || echo "WireGuard not running"
	@echo ""
	@echo "=== SSH Status ==="
	@netstat -tlnp 2>/dev/null | grep ':22 ' || echo "SSH not listening on port 22"
	@echo ""
	@echo "=== VPS Connection ==="
	@ping -c 1 -W 2 10.13.13.1 >/dev/null 2>&1 && echo "VPS reachable" || echo "VPS unreachable"

stop-wsl:
	@echo "Stopping WSL services..."
	@sudo wg-quick down tunnel 2>/dev/null || echo "WireGuard already down"
	@sudo pkill -f "sshd.*listener" 2>/dev/null || echo "SSH not running"
	@echo "Services stopped"

start-wsl:
	@echo "Starting WSL services..."
	@sudo mkdir -p /run/sshd
	@sudo wg-quick up tunnel
	@sudo /usr/sbin/sshd
	@echo "Services started"
