# Order Processing

## Overview

Full order lifecycle from cart checkout to delivery tracking.

## Requirements

- Place orders from cart contents
- Order states: pending -> confirmed -> shipped -> delivered
- Track order status and history
- View past orders
- Failed orders are retried up to 3 times before being marked as failed

## Pipeline Implementation

Orders are processed asynchronously using core.async:

```clojure
(defn start-order-pipeline []
  (async/pipeline 4
    processed-ch
    (map process-order)
    order-ch))
```

The pipeline uses 4 worker threads. Each order goes through validation, payment processing, and inventory reservation.

## Order States

- `pending` - Just placed, awaiting processing
- `confirmed` - Payment verified, inventory reserved
- `shipped` - Handed off to fulfillment
- `delivered` - Received by customer
- `failed` - Processing failed after 3 retries

## Related

See the [Order Pipeline](../technical/order-pipeline.md) documentation for more technical details.
