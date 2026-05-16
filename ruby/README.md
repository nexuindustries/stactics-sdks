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
```

Use a `st_secret_...` key for server-side Ruby apps.
