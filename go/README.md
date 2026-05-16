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
```

Run tests from this folder:

```sh
go test ./...
```
