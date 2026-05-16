# Stactics JavaScript SDK

Universal JavaScript client for the Stactics ingest API.

```js
import { StacticsClient } from "@stactics/js";

const stactics = new StacticsClient({
  apiKey: "st_live_...",
});

await stactics.track("signup", {
  userId: "user_123",
  environment: "production",
  metadata: { plan: "free" },
});
```

Use `st_live_...` in browsers and `st_secret_...` in trusted server-side JavaScript.
