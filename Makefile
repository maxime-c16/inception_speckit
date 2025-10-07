
# =============================
#  Makefile for Inception 42
# =============================

# Docker Compose file location
DOCKER_COMPOSE = docker-compose -f srcs/docker-compose.yml

.PHONY: all up down build clean fclean re logs ps restart test test-integration test-performance test-unit scan-secrets

# --- Main 42 Inception Targets ---
all: build

build:
	@echo "\033[1;34m[~] Building all services...\033[0m"
	$(DOCKER_COMPOSE) build

up:
	@echo "\033[1;32m[+] Starting all services...\033[0m"
	$(DOCKER_COMPOSE) up -d

down:
	@echo "\033[1;31m[-] Stopping all services...\033[0m"
	$(DOCKER_COMPOSE) down

clean:
	@echo "\033[1;33m[!] Cleaning up containers, volumes, and orphans...\033[0m"
	$(DOCKER_COMPOSE) down -v --remove-orphans

fclean: clean
	@echo "\033[1;33m[!] Full clean: removing all images, volumes, and networks...\033[0m"
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans
	@docker system prune -af --volumes 2>/dev/null || true

re: fclean all

logs:
	@$(DOCKER_COMPOSE) logs --tail=100 -f

ps:
	@$(DOCKER_COMPOSE) ps

restart:
	@echo "\033[1;35m[~] Restarting all services...\033[0m"
	$(DOCKER_COMPOSE) restart

# --- Test Orchestration ---
test: test-integration test-performance test-unit
	@echo "\033[1;32m[✔] All tests completed.\033[0m"

test-integration:
	@echo "\033[1;36m[TEST] Running integration tests...\033[0m"
	@for f in tests/integration/*.sh; do \
	  [ "$${f##*/}" = "test_ftp.sh" ] && continue; \
	  echo "\033[1;36m→ $$f\033[0m"; \
	  sh "$$f" || exit 1; \
	done

test-performance:
	@echo "\033[1;36m[TEST] Running performance tests...\033[0m"
	@for f in tests/performance/*.sh; do \
	  echo "\033[1;36m→ $$f\033[0m"; \
	  sh "$$f" || exit 1; \
	done

test-unit:
	@echo "\033[1;36m[TEST] Running unit tests...\033[0m"
	@for f in tests/unit/*.sh; do \
	  echo "\033[1;36m→ $$f\033[0m"; \
	  sh "$$f" || exit 1; \
	done

scan-secrets:
	@echo "\033[1;33m[!] Run secret scanning (see .pre-commit-config.yaml or CI config)\033[0m"
