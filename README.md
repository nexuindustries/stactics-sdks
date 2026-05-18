# Stactics SDKs

Official SDKs for sending events to Stactics.

SDKs target the public ingest API only:

- `POST /v1/events`
- `POST /v1/events/batch`

Packages:

- `ruby/`: `stactics` Ruby gem for Ruby and Rails backends.
- `js/`: `@stactics.io/js` universal JavaScript client for browser and server-side JavaScript.
- `angular/`: `@stactics.io/angular` Angular provider and service wrapper around `@stactics.io/js`.
- `go/`: Go module for trusted Go services and jobs.
- `rust/`: Rust crate for async backend/event producer usage.
- `swift/`: Swift Package Manager library for Apple-platform apps and server-side Swift.
- `kotlin/`: JVM/Android library with Kotlin APIs and Java interop under the `app.stactics:stactics-android` coordinates.

Use `sk_...` keys on trusted servers and `pk_...` keys in browser/mobile clients.

## Publishing

- Ruby: publish `ruby/` to RubyGems as `stactics`.
- JavaScript: publish `js/` to npm as `@stactics.io/js`.
- Angular: build `angular/` with ng-packagr and publish the generated package as `@stactics.io/angular`.
- Go and Swift are distributed from this public GitHub repository with version tags.
- Rust can be published to crates.io as `stactics`.
- Kotlin/JVM can be published to Maven Central as `app.stactics:stactics-android`.
