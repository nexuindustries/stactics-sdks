Gem::Specification.new do |spec|
  spec.name = "stactics"
  spec.version = "0.1.0"
  spec.authors = [ "Nexu Industries" ]
  spec.email = [ "support@stactics.app" ]

  spec.summary = "Ruby SDK for the Stactics ingest API"
  spec.description = "Track analytics events from Ruby and Rails apps with Stactics."
  spec.homepage = "https://github.com/nexuindustries/stactics-sdks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir["lib/**/*.rb", "README.md"]
  spec.require_paths = [ "lib" ]
end
