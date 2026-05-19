# Stactics JavaScript SDK

Universal JavaScript client for the Stactics ingest API.

```js
import { StacticsClient, StacticsEvents } from "@stactics.io/js";

const stactics = new StacticsClient({
  apiKey: "pk_...",
});

await stactics.trackEvent(StacticsEvents.signup({
  userId: "user_123",
  email: "founder@example.com",
  displayName: "Sam Founder",
  metadata: { plan: "free" },
}));

await stactics.trackEvent(StacticsEvents.login({
  userId: "user_123",
  email: "founder@example.com",
  displayName: "Sam Founder",
  deviceId: "install_abc",
  platform: "web",
}));

await stactics.trackEvent(StacticsEvents.purchase({
  userId: "user_123",
  accountId: "team_123",
  amountCents: 1299,
  currency: "AUD",
  metadata: { transactionId: "txn_123", productId: "pro_monthly" },
}));

await stactics.trackEvent(StacticsEvents.screenViewed({
  userId: "user_123",
  platform: "web",
  metadata: { path: "/dashboard" },
}));

await stactics.trackEvent(StacticsEvents.error({
  userId: "user_123",
  platform: "web",
  metadata: { error: "Payment provider timeout", context: "checkout" },
}));
```

Use `pk_...` in browsers and `sk_...` in trusted server-side JavaScript.

`StacticsEventTypes` exposes the default event names and `StacticsEvents` builds typed payloads for `signup`, `login`, `active`, `purchase`, `subscriptionStarted`, `subscriptionCancelled`, `trialStarted`, `trialConverted`, `crash`, `error`, `appOpened`, `screenViewed`, `featureUsed`, `notificationSent`, `notificationOpened`, and `healthCheck`.

For revenue events, send both `amountCents` and `currency`. Put transaction IDs, product IDs, receipt IDs, feature names, screen names, error details, and notification details in `metadata`.
