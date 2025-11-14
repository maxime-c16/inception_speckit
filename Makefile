
# =============================
#  Makefile for Inception 42
# =============================

# Docker Compose file location
DOCKER_COMPOSE = docker-compose --env-file srcs/.env -f srcs/docker-compose.yml
DATA_DIRS = /home/macauchy/data /home/macauchy/data/mariadb /home/macauchy/data/wordpress

.PHONY: all up down build clean fclean re logs ps restart scan-secrets prepare-data-dirs

# --- Main 42 Inception Targets ---
all: build up

build:
	@echo "\033[1;34m[~] Building all services...\033[0m"
	$(DOCKER_COMPOSE) build

up: prepare-data-dirs
	@echo "\033[1;32m[+] Starting all services...\033[0m"
	$(DOCKER_COMPOSE) up -d

down:
	@echo "\033[1;31m[-] Stopping all services...\033[0m"
	$(DOCKER_COMPOSE) down

clean:
	@echo "\033[1;33m[!] Cleaning up containers, volumes, and orphans...\033[0m"
	$(DOCKER_COMPOSE) down -v --remove-orphans

fclean: clean
	@echo "\033[1;33m[!] Performing full cleanup...\033[0m"
	@rm -rf /home/macauchy/data/mariadb/* /home/macauchy/data/wordpress/* 2>/dev/null || true
	@sudo docker system prune -af --volumes

restart:
	@echo "\033[1;35m[~] Restarting all services...\033[0m"
	$(DOCKER_COMPOSE) restart

prepare-data-dirs:
	@for dir in $(DATA_DIRS); do \
		if [ ! -d $$dir ]; then \
			echo "\033[1;34m[~] Creating data directory $$dir\033[0m"; \
			mkdir -p $$dir; \
		fi; \
	done
	@chmod 775 /home/macauchy/data /home/macauchy/data/mariadb /home/macauchy/data/wordpress 2>/dev/null || true

scan-secrets:
	@echo "\033[1;33m[!] Run secret scanning (see .pre-commit-config.yaml or CI config)\033[0m"
