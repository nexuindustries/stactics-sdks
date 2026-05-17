# Stactics Android/JVM SDK

Android/JVM client for the public Stactics ingest API. Kotlin and Java callers use the same `app.stactics:stactics-android` artifact.

```kotlin
implementation("app.stactics:stactics-android:0.1.1")
```

```kotlin
val stactics = StacticsClient(apiKey = BuildConfig.STACTICS_PUBLIC_KEY)

stactics.track(
    eventType = "signup",
    userId = "user_123",
    environment = "production",
    metadata = mapOf("plan" to "free")
)

stactics.track(
    eventType = "purchase",
    userId = "user_123",
    amountCents = 1299,
    currency = "AUD",
    metadata = mapOf("transaction_id" to "txn_123")
)
```

Run tests from this folder:

```sh
gradle test
```
