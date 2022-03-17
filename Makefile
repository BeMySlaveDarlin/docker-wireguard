all: build start

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
