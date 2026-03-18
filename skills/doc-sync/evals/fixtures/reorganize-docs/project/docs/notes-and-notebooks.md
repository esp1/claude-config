# Notes & Notebooks

## Notes

Users can create, edit, and organize notes. Notes support Markdown formatting and can be tagged for searching.

### Requirements

- Create notes with title, body (Markdown), and optional tags
- Edit note title, body, and tags
- Delete notes (soft delete with 30-day recovery)
- List all notes with pagination and sorting (by date, title)
- Filter notes by tag, notebook, or date range

### Note Storage

Notes are stored in the `notes` table:

```sql
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  notebook_id UUID REFERENCES notebooks(id),
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  tags TEXT[] DEFAULT '{}',
  search_vector tsvector,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TRIGGER notes_search_update
  BEFORE INSERT OR UPDATE ON notes
  FOR EACH ROW EXECUTE FUNCTION
  tsvector_update_trigger(search_vector, 'pg_catalog.english', title, body);
```

## Notebooks

Notes are grouped into notebooks for organization.

### Requirements

- Create notebooks with a name
- Rename notebooks
- Delete notebooks (moves notes to "Unfiled" notebook)
- Each user has a default "Unfiled" notebook created on registration
- List notebooks with note count

### Implementation

Notebooks use a simple CRUD pattern in `notesync.notebooks`:

```clojure
(defn create-notebook [user-id name]
  (db/execute-one! ["INSERT INTO notebooks (user_id, name) VALUES (?, ?)"
                     user-id name]))

(defn delete-notebook [user-id notebook-id]
  (jdbc/with-transaction [tx (db/ds)]
    ;; Move notes to Unfiled
    (jdbc/execute! tx ["UPDATE notes SET notebook_id = (SELECT id FROM notebooks WHERE user_id = ? AND name = 'Unfiled') WHERE notebook_id = ?" user-id notebook-id])
    ;; Delete the notebook
    (jdbc/execute! tx ["DELETE FROM notebooks WHERE id = ? AND user_id = ?" notebook-id user-id])))
```
