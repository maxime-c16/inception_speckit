
# =============================
#  Makefile for Inception 42
# =============================

.PHONY: up down build clean logs ps restart test test-integration test-performance test-unit scan-secrets

# --- Docker Compose Orchestration ---
up:
	@echo "\033[1;32m[+] Starting all services...\033[0m"
	docker-compose up -d

down:
	@echo "\033[1;31m[-] Stopping all services...\033[0m"
	docker-compose down

build:
	@echo "\033[1;34m[~] Building all services...\033[0m"
	docker-compose build

clean:
	@echo "\033[1;33m[!] Cleaning up containers, volumes, and orphans...\033[0m"
	docker-compose down -v --remove-orphans

logs:
	@docker-compose logs --tail=100 -f

ps:
	@docker-compose ps

restart:
	@echo "\033[1;35m[~] Restarting all services...\033[0m"
	docker-compose restart

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
