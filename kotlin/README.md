# Stactics Android/JVM SDK

Android/JVM client for the public Stactics ingest API. Kotlin and Java callers use the same `app.stactics:stactics-android` artifact.

```kotlin
implementation("app.stactics:stactics-android:0.1.4")
```

```kotlin
val stactics = StacticsClient(apiKey = BuildConfig.STACTICS_PUBLIC_KEY)

stactics.track(StacticsEvent(
    eventType = "signup",
    userId = "user_123",
    environment = "production",
    metadata = mapOf(
        "plan" to "free",
        "email" to "founder@example.com",
        "display_name" to "Sam Founder",
    ),
))

stactics.track(StacticsEvent(
    eventType = "login",
    userId = "user_123",
    deviceId = "install_abc",
    platform = "android",
    metadata = mapOf(
        "email" to "founder@example.com",
        "display_name" to "Sam Founder",
    ),
))

stactics.track(StacticsEvent(
    eventType = "purchase",
    userId = "user_123",
    amountCents = 1299,
    currency = "AUD",
    metadata = mapOf(
        "transaction_id" to "txn_123",
        "product_id" to "pro_monthly",
    ),
))

stactics.track(StacticsEvent(
    eventType = "screen_viewed",
    userId = "user_123",
    platform = "android",
    metadata = mapOf("screen" to "Dashboard")
))

stactics.track(StacticsEvent(
    eventType = "error",
    userId = "user_123",
    platform = "android",
    metadata = mapOf(
        "error" to "Payment provider timeout",
        "context" to "checkout",
    ),
))
```

For revenue events, send both `amountCents` and `currency`. Put transaction IDs, product IDs, screen names, feature names, error details, and notification details in `metadata`.

Submit form values without retrieving form definitions through the SDK:

```kotlin
val result = stactics.submitForm(
    formKey = "contact",
    fieldData = mapOf(
        "name" to "Ada Founder",
        "email" to "ada@example.com",
        "message" to "I would like to discuss a technical collaboration.",
        "consent" to true,
    ),
    source = "android",
    externalUserId = "visitor_123",
)
```

Run tests from this folder:

```sh
gradle test
```
