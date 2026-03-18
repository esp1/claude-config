# Deployment

## Building

```bash
clojure -T:build uber    # Build uberjar
```

The uberjar is output to `target/notesync.jar`.

## Running in Production

```bash
java -jar target/notesync.jar
```

All configuration is via environment variables (see README.md for the full list).

## Docker

```dockerfile
FROM eclipse-temurin:21-jre
COPY target/notesync.jar /app/notesync.jar
EXPOSE 3000
CMD ["java", "-jar", "/app/notesync.jar"]
```

## Database Migrations

Run before each deploy:

```bash
clojure -M:migrate
```

Migrations are in `resources/migrations/` and use a sequential numbering scheme.

## Health Check

`GET /health` returns `200 OK` with `{"status": "ok"}` when the server is running and connected to both PostgreSQL and Redis.
