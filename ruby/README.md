# Stactics Ruby SDK

Ruby client for the Stactics ingest API.

```ruby
client = Stactics::Client.new(api_key: ENV.fetch("STACTICS_SECRET_KEY"))

client.track(
  "signup",
  user_id: "user_123",
  email: "founder@example.com",
  environment: "production",
  metadata: { plan: "free" }
)

client.track(
  "purchase",
  user_id: "user_123",
  amount_cents: 1299,
  currency: "AUD",
  metadata: { transaction_id: "txn_123" }
)
```

Use a `sk_...` key for server-side Ruby apps.
