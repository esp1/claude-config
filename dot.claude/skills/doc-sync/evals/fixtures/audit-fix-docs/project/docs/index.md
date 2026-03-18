# ShopAPI Documentation

ShopAPI is a complete e-commerce backend API built with Clojure and PostgreSQL.

## Quick Start

```bash
clojure -P              # Install dependencies
createdb shopapi        # Create the database
clojure -M:migrate      # Run migrations
clojure -M:dev          # Start dev server (port 3000)
```

See [Development Guide](technical/development.md) for full setup details and commands.

## Features

- **Product Catalog** - Browse, search, and filter products with full-text search
- **Shopping Cart** - Persistent cart management with inventory validation
- **Order Processing** - Full order lifecycle from checkout to delivery

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

- **[Product Catalog](functional/product-catalog.md)** - Product browsing and search requirements
- **[Shopping Cart](functional/shopping-cart.md)** - Cart management requirements
- **[Order Processing](functional/order-processing.md)** - Order lifecycle requirements
- **[Architecture](technical/architecture.md)** - System design and components
- **[Development Guide](technical/development.md)** - Setup, commands, and workflows
- **[Order Pipeline](technical/order-pipeline.md)** - core.async order processing pipeline
