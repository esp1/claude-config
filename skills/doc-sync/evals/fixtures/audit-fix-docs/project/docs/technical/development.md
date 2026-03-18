# Development Guide

## Prerequisites

- JDK 21+
- Clojure CLI tools
- PostgreSQL 16+

## Setup

```bash
# Install dependencies
clojure -P

# Create the database
createdb shopapi

# Run migrations
clojure -M:migrate

# Start dev server
clojure -M:dev
```

The server runs on port 3000 by default. Set the `PORT` environment variable to change it.

## Commands

- `clojure -M:dev` — Start dev server with hot reload
- `clojure -M:test` — Run test suite
- `clojure -M:migrate` — Run database migrations
- `clojure -M:repl` — Start nREPL
