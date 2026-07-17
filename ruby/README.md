# Stactics Ruby SDK

Ruby client for the Stactics ingest API.

```ruby
client = Stactics::Client.new(api_key: ENV.fetch("STACTICS_SECRET_KEY"))

client.track(
  "signup",
  user_id: "user_123",
  email: "founder@example.com",
  display_name: "Sam Founder",
  environment: "production",
  metadata: { plan: "free" }
)

client.track(
  "login",
  user_id: "user_123",
  email: "founder@example.com",
  display_name: "Sam Founder",
  device_id: "install_abc",
  platform: "web"
)

client.track(
  "purchase",
  user_id: "user_123",
  account_id: "team_123",
  amount_cents: 1299,
  currency: "AUD",
  metadata: { transaction_id: "txn_123", product_id: "pro_monthly" }
)

client.track(
  "screen_viewed",
  user_id: "user_123",
  platform: "web",
  metadata: { path: "/dashboard" }
)

client.track(
  "error",
  user_id: "user_123",
  platform: "web",
  metadata: { error: "Payment provider timeout", context: "checkout" }
)
```

Use a `sk_...` key for server-side Ruby apps.

Submit form values without retrieving form definitions through the SDK:

```ruby
client.submit_form(
  "contact",
  {
    name: "Ada Founder",
    email: "ada@example.com",
    message: "I would like to discuss a technical collaboration.",
    consent: true
  },
  source: "ruby",
  external_user_id: "visitor_123"
)
```

Form field keys are preserved rather than converted to event-style snake case.

For revenue events, send both `amount_cents` and `currency`. Put transaction IDs, product IDs, screen names, feature names, error details, and notification details in `metadata`.
