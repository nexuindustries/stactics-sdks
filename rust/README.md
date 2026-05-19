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

client.track(Event::new("login")
    .user_id("user_123")
    .metadata(json!({
        "email": "founder@example.com",
        "display_name": "Sam Founder"
    })))
    .await?;

client.track(Event::new("purchase")
    .user_id("user_123")
    .amount_cents(1299)
    .currency("AUD")
    .metadata(json!({
        "transaction_id": "txn_123",
        "product_id": "pro_monthly"
    })))
    .await?;

client.track(Event::new("screen_viewed")
    .user_id("user_123")
    .metadata(json!({ "path": "/dashboard" })))
    .await?;

client.track(Event::new("error")
    .user_id("user_123")
    .metadata(json!({
        "error": "Payment provider timeout",
        "context": "checkout"
    })))
    .await?;
```

For revenue events, send both `amount_cents` and `currency`. Put transaction IDs, product IDs, screen names, feature names, error details, and notification details in `metadata`.

Run tests from this folder:

```sh
cargo test
```
