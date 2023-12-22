# GoLang Backend thinkIT - Laundry SQLC Migration & Models

---

## Local Run SQLC

- Setup database (local) to create database schema equal with config `(schema: "think_laundry-dev")`
- Setup Makefile param for migration connection database ex: `PG_DB_URL=postgresql://postgres:postgres@localhost:5439/think_laundry-dev?sslmode=disable`
- run mod=vendor dependency with `make deps`
- Up / Run migrate with `make run pg.migrate.up` (Use WSL for OS Windows)

## API Docs

### [Postman API Docs]

## License

[© 2023 thinkIT]
