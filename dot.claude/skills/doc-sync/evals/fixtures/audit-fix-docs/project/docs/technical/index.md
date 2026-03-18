# Technical Documentation

## Tech Stack

- Clojure 1.12
- Ring + Reitit for HTTP
- PostgreSQL 16 with next.jdbc
- buddy-auth for JWT
- core.async for order pipeline

## API Endpoints

All endpoints are under `/api/v1`:

- `POST /api/v1/auth/register` -- Create account
- `POST /api/v1/auth/login` -- Get JWT token
- `GET /api/v1/products` -- List products
- `GET /api/v1/products/:id` -- Get product
- `POST /api/v1/cart/items` -- Add to cart
- `GET /api/v1/cart` -- View cart
- `POST /api/v1/orders` -- Place order
- `GET /api/v1/orders` -- Order history

## Documentation

- **[Architecture](architecture.md)** - System design and components
- **[Development Guide](development.md)** - Setup, commands, and workflows
- **[Order Pipeline](order-pipeline.md)** - core.async order processing pipeline
