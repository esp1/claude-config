# ShopAPI

An e-commerce API built with Clojure and PostgreSQL.

## Tech Stack

- Clojure 1.12 with Ring and Reitit
- PostgreSQL 16 with next.jdbc
- buddy-auth for JWT authentication
- core.async for order processing pipeline

## Quick Start

```bash
clojure -P              # Install dependencies
createdb shopapi        # Create the database
clojure -M:migrate      # Run migrations
clojure -M:dev          # Start dev server (port 3000)
```

## Features

- **Product Catalog** - Browse, search, and filter products with full-text search
- **Shopping Cart** - Persistent cart with inventory validation
- **Order Processing** - Async order pipeline with retry logic

## API Endpoints

All endpoints under `/api/v1`:

- `POST /api/v1/auth/register` - Create account
- `POST /api/v1/auth/login` - Get JWT token
- `GET /api/v1/products` - List products
- `GET /api/v1/products/:id` - Get product
- `POST /api/v1/cart/items` - Add to cart
- `GET /api/v1/cart` - View cart
- `POST /api/v1/orders` - Place order
- `GET /api/v1/orders` - Order history

For full documentation, see [docs/index.md](docs/index.md).
