NAME			:= inception
COMPOSE_FILE	:= srcs/docker-compose.yml

BLUE	:= \033[1;34m
GREEN	:= \033[1;32m
YELL	:= \033[1;33m
RESET	:= \033[0m

up-d:
	@echo "$(BLUE)🚀 Starting $(NAME) (foreground mode)...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up --build -d

up:
	@echo "$(BLUE)🚀 Starting $(NAME) (foreground mode)...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up --build
	@echo "$(GREEN)✓ $(NAME) stopped (Ctrl+C was pressed).$(RESET)"

down:
	@echo "$(YELL)🛑 Stopping $(NAME)...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down

re: down up-d

ps:
	@docker compose -f $(COMPOSE_FILE) ps

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: up up-d down re ps logs
