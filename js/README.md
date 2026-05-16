# Stactics JavaScript SDK

Universal JavaScript client for the Stactics ingest API.

```js
import { StacticsClient } from "@stactics/js";

const stactics = new StacticsClient({
  apiKey: "pk_...",
});

await stactics.track("signup", {
  userId: "user_123",
  environment: "production",
  metadata: { plan: "free" },
});
```

Use `pk_...` in browsers and `sk_...` in trusted server-side JavaScript.
