# Sharing & Collaboration

## Overview

Notes and notebooks can be shared with other users for collaborative editing. Changes to shared notes are synchronized in real time via WebSocket connections backed by Redis pub/sub.

## Requirements

- Share a note with another user by email
- Set permission level: read-only or read-write
- Revoke sharing access
- Note owner can see all collaborators
- Shared notes appear in the recipient's "Shared with me" view
- Real-time sync: when a collaborator edits a shared note, all other viewers see changes immediately

## Real-Time Sync Architecture

```
Client A (edit) → WebSocket → Server → Redis pub/sub → Server → WebSocket → Client B (update)
```

The sync module (`notesync.sync`) manages connections and message routing:

```clojure
(defn on-note-edit [note-id user-id patch]
  ;; Broadcast edit to all other viewers of this note
  (let [msg {:type :edit
             :note-id note-id
             :user-id user-id
             :patch patch
             :timestamp (System/currentTimeMillis)}]
    (redis/publish (str "note:" note-id) (pr-str msg))))
```

Each WebSocket connection subscribes to the Redis channel for the note being viewed. When an edit comes in, it's broadcast to all subscribers except the sender.

## Access Control

Sharing is tracked in the `note_shares` table:

```sql
CREATE TABLE note_shares (
  note_id UUID REFERENCES notes(id),
  user_id UUID REFERENCES users(id),
  permission VARCHAR(10) CHECK (permission IN ('read', 'write')),
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (note_id, user_id)
);
```

The `notesync.sharing` namespace checks permissions before allowing reads or writes on shared notes.

## Acceptance Criteria

- Sharing a note sends no notification (future feature)
- Revoking access immediately disconnects the user's WebSocket for that note
- A user with read-only access cannot edit via the API or WebSocket
- Deleting a shared note revokes all shares
