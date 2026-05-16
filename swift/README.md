# Stactics Swift SDK

Swift Package Manager library for Apple-platform apps and server-side Swift.

```swift
.package(url: "https://github.com/nexuindustries/stactics-sdks", from: "0.1.0")
```

```swift
let client = StacticsClient(apiKey: publicKey)

try await client.track(
    "signup",
    userId: "user_123",
    environment: "production",
    metadata: ["plan": "free"]
)
```

Run tests from this folder:

```sh
swift test
```
