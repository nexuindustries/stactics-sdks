# Stactics SDKs

Official SDKs for sending events to Stactics.

SDKs target the public ingest API only:

- `POST /v1/events`
- `POST /v1/events/batch`
- `POST /v1/forms/:form_key/submissions`

SDKs submit form values only. Form-definition retrieval, rendering, and management remain application responsibilities.

Packages:

- `ruby/`: `stactics` Ruby gem for Ruby and Rails backends.
- `js/`: `@stactics/js` universal JavaScript client for browser and server-side JavaScript.
- `angular/`: `@stactics/angular` Angular provider and service wrapper around `@stactics/js`.
- `go/`: Go module for trusted Go services and jobs.
- `rust/`: Rust crate for async backend/event producer usage.
- `swift/`: Swift Package Manager library for Apple-platform apps and server-side Swift.
- `kotlin/`: JVM/Android library with Kotlin APIs and Java interop under the `app.stactics:stactics-android` coordinates.

Use `sk_...` keys on trusted servers and `pk_...` keys in browser/mobile clients.

## Event Payload Guide

All SDKs send events to the same ingest API. SDKs may expose idiomatic camelCase names, but the API stores the core fields as snake_case.

Common fields:

- Identity: `user_id` / `userId`, `account_id` / `accountId`, `email`, `username`, `display_name` / `displayName`, `device_id` / `deviceId`
- App context: `platform`, `build_version` / `buildVersion`, `environment_id` / `environmentId`
- Revenue: `amount_cents` / `amountCents` and `currency`
- Event details: `metadata`

Form submissions send the configured field map as `fieldData` and preserve its keys exactly and are never sent through event batching APIs.

Default event types:

- `signup`: user created an account. Include user/account identity and `metadata.plan` when known.
- `login`: successful authentication. Include user details such as `userId`, `email`, and `displayName`.
- `active`: meaningful active-user heartbeat or qualified session. Include user/device identity and `metadata.sessionId`.
- `purchase`: successful payment. Include `amountCents` and `currency`; put transaction or product IDs in `metadata`.
- `subscription_started`: paid subscription started. Include `amountCents`, `currency`, `metadata.plan`, and `metadata.interval`.
- `subscription_cancelled`: subscription cancelled. Include `metadata.plan` and `metadata.reason` when known.
- `trial_started`: trial started. Include `metadata.plan` and `metadata.trialDays`.
- `trial_converted`: trial became paid. Include `amountCents`, `currency`, and `metadata.plan`.
- `crash`: fatal failure. Include device/app context and `metadata.error`, `metadata.stack`, or `metadata.screen`.
- `error`: handled error worth tracking. Include app context and `metadata.error` plus `metadata.context`.
- `app_opened`: app or site session started. Include device/app context.
- `screen_viewed`: screen or page viewed. Include `metadata.screen` or `metadata.path`.
- `feature_used`: meaningful feature action. Include `metadata.feature` and `metadata.action`.
- `notification_sent`: notification accepted by the sending provider. Include `metadata.notificationId`, `metadata.channel`, and `metadata.template`.
- `notification_opened`: user opened a notification. Include user/device identity and notification metadata.
- `health_check`: monitor or job proved ingest is alive. Include `metadata.source` and `metadata.check`.

JavaScript and Angular also export `StacticsEventTypes` and `StacticsEvents` helpers for the default event catalog.

## Publishing

- Ruby: publish `ruby/` to RubyGems as `stactics`.
- JavaScript: publish `js/` to npm as `@stactics/js`.
- Angular: build `angular/` with ng-packagr and publish the generated package as `@stactics/angular`.
- Go and Swift are distributed from this public GitHub repository with version tags.
- Rust can be published to crates.io as `stactics`.
- Kotlin/JVM can be published to Maven Central as `app.stactics:stactics-android`.
