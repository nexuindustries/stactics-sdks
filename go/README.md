# Stactics Go SDK

Thin Go client for the public Stactics ingest API.

```sh
go get github.com/nexuindustries/stactics-sdks/go/stactics
```

```go
client := stactics.NewClient(os.Getenv("STACTICS_SECRET_KEY"))

_, err := client.Track(context.Background(), "signup", stactics.Event{
    UserID: "user_123",
    Environment: "production",
    Metadata: map[string]any{"plan": "free"},
})

_, err = client.Track(context.Background(), "purchase", stactics.Event{
    UserID: "user_123",
    AmountCents: 1299,
    Currency: "AUD",
    Metadata: map[string]any{"transaction_id": "txn_123"},
})
```

Run tests from this folder:

```sh
go test ./...
```
