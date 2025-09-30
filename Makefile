 NAME            := inception
DOCKER_COMPOSE  := docker compose
COMPOSE_FILE    := srcs/docker-compose.yml

BLUE  := \033[1;34m
GREEN := \033[1;32m
YELL  := \033[1;33m
RESET := \033[0m

.PHONY: up down re ps logs

up:
	@echo "$(BLUE)🚀 Starting $(NAME) (foreground mode)...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up --build
	@echo "$(GREEN)✓ $(NAME) stopped (Ctrl+C was pressed).$(RESET)"

down:
	@echo "$(YELL)🛑 Stopping $(NAME)...$(RESET)"
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

re: down up

ps:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) ps

logs:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) logs -f