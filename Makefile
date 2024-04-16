ifeq ($(wildcard .env),)
    $(shell cp .env.example .env)
endif

include .env
export


## ---------- UTILS
.PHONY: help
help: ## Show this menu
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: clean
clean: ## Clean all temp files
	@rm -rf tmp/



## ---------- INSTALL
.PHONY: install-migrate
install-migrate: ## install migrate
	@if [ ! -f /usr/local/bin/migrate ]; then \
		wget -O /tmp/migrate.tar.gz https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz; \
		tar -C /tmp -xzvf /tmp/migrate.tar.gz; \
		sudo mv /tmp/migrate /usr/local/bin/migrate; \
	else \
		echo "Great, you already have [migrate] installed"; \
	fi

.PHONY: install-sqlc
install-sqlc: ## install sqlc
	@if [ ! -f ~/.go/bin/sqlc ]; then \
		go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest; \
	else \
		echo "Great, you already have [sqlc] installed"; \
	fi

.PHONY: install
install: install-migrate install-sqlc ## install all requirements



## ---------- MIGRATIONS
.PHONY: migration_init
migration_init: ## init migrations
	@migrate create -ext=sql -dir=sql/migrations -seq init

.PHONY: migration_up
migration_up: ## run migrations up
	@migrate -path=sql/migrations -database "mysql://root:${MYSQL_ROOT_PASSWORD}@tcp(localhost:3306)/${MYSQL_DATABASE}" -verbose up
	@docker exec -it -e MYSQL_PASSWORD=root mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -D ${MYSQL_DATABASE} -e "show tables;"

.PHONY: migration_down
migration_down: ## run migrations down
	@migrate -path=sql/migrations -database "mysql://root:${MYSQL_ROOT_PASSWORD}@tcp(localhost:3306)/${MYSQL_DATABASE}" -verbose down --all
	@docker exec -it -e MYSQL_PASSWORD=root mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -D ${MYSQL_DATABASE} -e "show tables;"

.PHONY: migration_clean
migration_clean: migration_down migration_up ## run migration down and up to cleanup all data



## ---------- COMPOSE
.PHONY: compose_up
compose_up: ## run docker-compose up
	@docker-compose up -d

.PHONY: compose.down
compose_down: ## run docker-compose down
	@docker-compose down



## ---------- MAIN
.PHONY: generate
generate: ## run sqls generate
	@sqlc generate

.PHONY: run
run: ## run the code
	@go run cmd/runSQLC/main.go
