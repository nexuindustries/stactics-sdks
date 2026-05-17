# Stactics Rust SDK

Async Rust client for the public Stactics ingest API.

```sh
cargo add stactics
```

```rust
let client = Client::new(std::env::var("STACTICS_SECRET_KEY").unwrap());

client.track(Event::new("signup")
    .user_id("user_123")
    .environment("production")
    .metadata(json!({ "plan": "free" })))
    .await?;

client.track(Event::new("purchase")
    .user_id("user_123")
    .amount_cents(1299)
    .currency("AUD")
    .metadata(json!({ "transaction_id": "txn_123" })))
    .await?;
```

Run tests from this folder:

```sh
cargo test
```
