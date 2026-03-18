# Product Catalog

## Overview

The product catalog allows users to browse, search, and filter products.

## Requirements

- Products have title, description, price, category, and inventory count
- Users can list all products with pagination
- Full-text search by keyword
- Filter by category, price range, and availability
- Sort by price, name, or date added

## Search Implementation

Full-text search is powered by PostgreSQL's tsvector:

```sql
CREATE TRIGGER products_search_update
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION
  tsvector_update_trigger(search_vector, 'pg_catalog.english', title, description);
```

Search queries use `to_tsvector` and `plainto_tsquery` for ranking results.
