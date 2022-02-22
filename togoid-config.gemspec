# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "togoid-config"
  spec.version       = "1.0.0"
  spec.authors       = ["Toshiaki Katayama"]
  spec.email         = ["k@bioruby.org"]

  spec.summary       = "TogoID-config: configuration of ."
  spec.description   = "TogoID update procedures and meadata for relations of ID pairs."
  spec.homepage      = "https://togoid.dbcls.jp/"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dbcls/togoid-config"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|config-)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end

