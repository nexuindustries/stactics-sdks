# Stactics JavaScript SDK

Universal JavaScript client for the Stactics ingest API.

```js
import { StacticsClient } from "@stactics.io/js";

const stactics = new StacticsClient({
  apiKey: "pk_...",
});

await stactics.track("signup", {
  userId: "user_123",
  environment: "production",
  metadata: { plan: "free" },
});

await stactics.track("purchase", {
  userId: "user_123",
  amountCents: 1299,
  currency: "AUD",
  metadata: { transactionId: "txn_123" },
});
```

Use `pk_...` in browsers and `sk_...` in trusted server-side JavaScript.
