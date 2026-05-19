# Stactics Go SDK

Thin Go client for the public Stactics ingest API.

```sh
go get github.com/nexuindustries/stactics-sdks/go/stactics
```

```go
client := stactics.NewClient(os.Getenv("STACTICS_SECRET_KEY"))

_, err := client.Track(context.Background(), "signup", stactics.Event{
    UserID: "user_123",
    Email: "founder@example.com",
    Environment: "production",
    Metadata: map[string]any{"plan": "free"},
})

_, err = client.Track(context.Background(), "login", stactics.Event{
    UserID: "user_123",
    Email: "founder@example.com",
    DeviceID: "install_abc",
    Platform: "web",
})

_, err = client.Track(context.Background(), "purchase", stactics.Event{
    UserID: "user_123",
    AccountID: "team_123",
    AmountCents: 1299,
    Currency: "AUD",
    Metadata: map[string]any{"transaction_id": "txn_123", "product_id": "pro_monthly"},
})

_, err = client.Track(context.Background(), "screen_viewed", stactics.Event{
    UserID: "user_123",
    Platform: "web",
    Metadata: map[string]any{"path": "/dashboard"},
})

_, err = client.Track(context.Background(), "error", stactics.Event{
    UserID: "user_123",
    Platform: "web",
    Metadata: map[string]any{"error": "Payment provider timeout", "context": "checkout"},
})
```

For revenue events, send both `AmountCents` and `Currency`. Put transaction IDs, product IDs, screen names, feature names, error details, and notification details in `Metadata`.

Run tests from this folder:

```sh
go test ./...
```
