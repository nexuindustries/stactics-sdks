# Publishing Stactics SDKs

This repository is designed to be public. Go and Swift distribution happens directly from the public GitHub repository and version tags. Registry packages need their own credentials.

## Release order

1. Confirm CI is green on `main`.
2. Tag the repo:

   ```sh
   git tag v0.1.1
   git push origin v0.1.1
   ```

3. Publish registry-backed packages.

## Ruby

```sh
cd ruby
gem build stactics.gemspec
gem push stactics-0.1.1.gem
```

Requires a RubyGems account with permission to own `stactics`.

## JavaScript

```sh
cd js
npm publish --access public
```

Requires npm login and access to publish under the `@stactics.io` scope.

## Angular

```sh
npm install
npm run build:angular
cd dist/angular
npm publish --access public
```

Requires npm login and access to publish under the `@stactics.io` scope.

## Go

After pushing the public repo and tag, Go users can install:

```sh
go get github.com/nexuindustries/stactics-sdks/go/stactics@v0.1.1
```

## Swift

After pushing the public repo and tag, Swift users can add:

```swift
.package(url: "https://github.com/nexuindustries/stactics-sdks", from: "0.1.1")
```

## Rust

```sh
cd rust
cargo publish
```

Requires a crates.io API token and package ownership for `stactics`.

## Kotlin/JVM

The Kotlin package is ready for Maven Central coordinates:

```text
app.stactics:stactics-android:0.1.1
```

Maven Central publishing still needs signing and Sonatype Central Portal configuration before first release.
