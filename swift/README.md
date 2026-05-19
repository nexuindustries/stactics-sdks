# Stactics Swift SDK

Swift Package Manager library for Apple-platform apps and server-side Swift.

```swift
.package(url: "https://github.com/nexuindustries/stactics-sdks", from: "0.1.2")
```

```swift
let client = StacticsClient(apiKey: publicKey)

try await client.track(
    "signup",
    userId: "user_123",
    environment: "production",
    metadata: ["plan": "free"]
)

try await client.track(
    "login",
    userId: "user_123",
    deviceId: "install_abc",
    platform: "ios",
    metadata: [
        "email": "founder@example.com",
        "display_name": "Sam Founder"
    ]
)

try await client.track(
    "purchase",
    userId: "user_123",
    amountCents: 1299,
    currency: "AUD",
    metadata: [
        "transaction_id": "txn_123",
        "product_id": "pro_monthly"
    ]
)

try await client.track(
    "screen_viewed",
    userId: "user_123",
    platform: "ios",
    metadata: ["screen": "Dashboard"]
)

try await client.track(
    "error",
    userId: "user_123",
    platform: "ios",
    metadata: [
        "error": "Payment provider timeout",
        "context": "checkout"
    ]
)
```

For revenue events, send both `amountCents` and `currency`. Put transaction IDs, product IDs, screen names, feature names, error details, and notification details in `metadata`.

Run tests from the repository root:

```sh
swift test
```
