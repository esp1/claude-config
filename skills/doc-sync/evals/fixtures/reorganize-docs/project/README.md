# NoteSync

A collaborative note-taking API with real-time sync, built with Clojure.

## Tech Stack

- Clojure 1.12 with Ring and Reitit
- PostgreSQL 16 with next.jdbc
- Redis for pub/sub real-time sync
- buddy-auth for JWT authentication

## Getting Started

### Prerequisites

- JDK 21+
- Clojure CLI tools
- PostgreSQL 16+
- Redis 7+

### Setup

```bash
clojure -P                  # Install dependencies
createdb notesync           # Create database
clojure -M:migrate          # Run migrations
redis-server &              # Start Redis
clojure -M:dev              # Start dev server (port 3000)
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 3000 | HTTP server port |
| DB_HOST | localhost | PostgreSQL host |
| DB_NAME | notesync | Database name |
| REDIS_URL | redis://localhost:6379 | Redis connection |
| JWT_SECRET | (required) | JWT signing secret |

## Features

### Notes
Users can create, edit, and organize notes into notebooks. Notes support Markdown formatting and can be tagged for easy searching.

### Notebooks
Notes are grouped into notebooks. Users can create, rename, and delete notebooks. Deleting a notebook moves its notes to "Unfiled."

### Sharing & Collaboration
Notes and notebooks can be shared with other users. Shared notes support real-time collaborative editing — changes are broadcast to all viewers via Redis pub/sub.

### Search
Full-text search across all notes using PostgreSQL tsvector. Results are ranked by relevance and recency.

## API Endpoints

### Authentication
- `POST /api/auth/register` — Create account
- `POST /api/auth/login` — Get JWT token
- `POST /api/auth/refresh` — Refresh token

### Notes
- `GET /api/notes` — List user's notes
- `POST /api/notes` — Create note
- `GET /api/notes/:id` — Get note
- `PUT /api/notes/:id` — Update note
- `DELETE /api/notes/:id` — Delete note

### Notebooks
- `GET /api/notebooks` — List notebooks
- `POST /api/notebooks` — Create notebook
- `PUT /api/notebooks/:id` — Rename notebook
- `DELETE /api/notebooks/:id` — Delete notebook

### Sharing
- `POST /api/notes/:id/share` — Share note with user
- `DELETE /api/notes/:id/share/:user-id` — Revoke access
- `GET /api/notes/:id/collaborators` — List collaborators

### WebSocket
- `GET /ws/notes/:id` — Real-time note sync (WebSocket upgrade)

## Architecture

Ring HTTP server with Reitit router. JWT middleware authenticates all `/api` routes. WebSocket connections are authenticated on upgrade.

### Components

- `notesync.core` — Server startup
- `notesync.routes` — Route definitions
- `notesync.db` — Connection pool and queries
- `notesync.auth` — JWT token management
- `notesync.notes` — Note CRUD operations
- `notesync.notebooks` — Notebook management
- `notesync.sharing` — Access control and collaboration
- `notesync.sync` — Redis pub/sub for real-time sync
- `notesync.search` — Full-text search with tsvector

## License

MIT
