# Search

Full-text search across all user-accessible notes (owned + shared).

## Requirements

- Search by keyword across note title and body
- Results ranked by relevance and recency
- Only returns notes the user owns or has been shared
- Pagination support

## Implementation

Search uses PostgreSQL's built-in full-text search with tsvector:

```clojure
(defn search-notes [user-id query & {:keys [limit offset] :or {limit 20 offset 0}}]
  (db/execute!
    ["SELECT n.id, n.title, ts_headline('english', n.body, plainto_tsquery('english', ?)) as snippet,
             ts_rank(n.search_vector, plainto_tsquery('english', ?)) as rank
      FROM notes n
      LEFT JOIN note_shares ns ON ns.note_id = n.id AND ns.user_id = ?
      WHERE (n.user_id = ? OR ns.user_id IS NOT NULL)
        AND n.deleted_at IS NULL
        AND n.search_vector @@ plainto_tsquery('english', ?)
      ORDER BY rank DESC, n.updated_at DESC
      LIMIT ? OFFSET ?"
     query query user-id user-id query limit offset]))
```

The `search_vector` column is automatically maintained by a trigger (see notes-and-notebooks.md).
