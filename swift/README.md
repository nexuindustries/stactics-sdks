# Stactics Swift SDK

Swift Package Manager library for Apple-platform apps and server-side Swift.

```swift
.package(url: "https://github.com/nexuindustries/stactics-sdks", from: "0.1.1")
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
    "purchase",
    userId: "user_123",
    amountCents: 1299,
    currency: "AUD",
    metadata: ["transaction_id": "txn_123"]
)
```

Run tests from this folder:

```sh
swift test
```
