NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
PG_MIGRATIONS_FOLDER=./scripts/pgbo/migrations
PG_DB_URL=postgresql://postgres:postgres@127.0.0.1:5432/think_laundry-dev?sslmode=disable

CMD_SQLC := $(shell command -v sqlc 2> /dev/null)
CMD_MIGRATE := $(shell command -v migrate 2> /dev/null)

check-migrations-cmd:
ifndef CMD_MIGRATE
	$(error "migrate is not installed, see: https://github.com/golang-migrate/migrate")
endif
ifndef CMD_SQLC
	$(error "sqlc is not installed, see: github.com/kyleconroy/sqlc)")
endif

gen.pg.models: check-migrations-cmd
	cd ./scripts/pgbo && sqlc generate

gen.pg.migration: check-migrations-cmd
	migrate create -ext sql -dir $(PG_MIGRATIONS_FOLDER) --seq $(name)

pg.migrate.up: check-migrations-cmd
	migrate -path $(PG_MIGRATIONS_FOLDER) -database $(PG_DB_URL) --verbose up

pg.migrate.down: check-migrations-cmd
	migrate -path $(PG_MIGRATIONS_FOLDER) -database $(PG_DB_URL) --verbose down

pg.migrate.fix: check-migrations-cmd
	migrate -path $(PG_MIGRATIONS_FOLDER) -database $(PG_DB_URL) force $(version)
