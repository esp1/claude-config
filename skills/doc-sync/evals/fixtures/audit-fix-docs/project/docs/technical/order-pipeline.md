# Order Processing Pipeline

## Overview

Orders are processed asynchronously using core.async channels.

## Pipeline Architecture

1. Order placed -> message on `order-channel`
2. `process-order` consumer validates inventory and payment
3. On success: order confirmed, inventory decremented
4. On failure: retry up to 3 times, then mark as failed

## Implementation

```clojure
(defn start-order-pipeline []
  (async/pipeline 4
    processed-ch
    (map process-order)
    order-ch))
```

Uses a fixed thread pool of 4 workers via `core.async/pipeline`.

## Order States

- `pending` - Just placed, awaiting processing
- `confirmed` - Payment verified, inventory reserved
- `shipped` - Handed off to fulfillment
- `delivered` - Received by customer
- `failed` - Processing failed after 3 retries
