# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: macauchy <macauchy@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/11/14 18:40:35 by macauchy          #+#    #+#              #
#    Updated: 2025/11/20 13:59:41 by macauchy         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DOCKER_COMPOSE = docker-compose --env-file srcs/.env -f srcs/docker-compose.yml
DATA_BASE_DIR = ./data
DATA_DIRS = $(DATA_BASE_DIR) $(DATA_BASE_DIR)/mariadb $(DATA_BASE_DIR)/wordpress

all: build
	@$(MAKE) up

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
	@rm -rf /home/macauchy/data/mariadb/* /home/macauchy/data/wordpress/* 2>/dev/null || true
	@docker system prune -af --volumes
	@echo "\033[1;33m[!] Note: If you encounter permission errors, run 'docker system prune -af --volumes' manually with sudo privileges.\033[0m"
	@sudo docker system prune -af --volumes

re: down
	@$(MAKE) build
	@$(MAKE) up

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
	@for dir in $(DATA_DIRS); do \
		chmod 775 $$dir 2>/dev/null || true; \
	done
	@chmod 775 /home/macauchy/data /home/macauchy/data/mariadb /home/macauchy/data/wordpress 2>/dev/null || true

.PHONY: all build up down clean fclean re restart prepare-data-dirs
