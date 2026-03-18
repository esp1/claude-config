# Architecture

## Tech Stack

- Clojure 1.12 with Ring and Reitit
- PostgreSQL 16 with next.jdbc and HikariCP
- buddy-auth for JWT authentication

## System Design

Ring HTTP server with Reitit routing. PostgreSQL database with HikariCP connection pooling.

## Components

- `shopapi.core` - Server startup and configuration
- `shopapi.routes` - API route definitions
- `shopapi.db` - Database connection pool and queries
- `shopapi.auth` - JWT token generation and validation
- `shopapi.products` - Product CRUD and search
- `shopapi.cart` - Cart operations
- `shopapi.orders` - Order processing pipeline
