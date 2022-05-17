# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = "yescode"
  spec.version       = "1.0.0"
  spec.author        = "Sean Walker"
  spec.email         = "sean@swlkr.com"

  spec.summary       = "A ruby mvc web framework"
  spec.description   = "This gem helps you write mvc web applications"
  spec.homepage      = "https://github.com/swlkr/yescode"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/swlkr/yescode"
    spec.metadata["changelog_uri"] = "https://github.com/swlkr/yescode/blob/main/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(docs|examples|test|Dockerfile|\.rubocop\.yml|\.solargraph\.yml|\.github)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.1.0"

  spec.add_development_dependency "minitest", "5.15.0"
  spec.add_development_dependency "rbs", "2.4.0"
  spec.add_development_dependency "steep", "0.52.2"

  spec.add_dependency "mail", "2.7.1"
  spec.add_dependency "net-smtp", "0.3.1"
  spec.add_dependency "rack", "2.2.3"
  spec.add_dependency "rack_csrf", "2.6.0"
  spec.add_dependency "sqlite3", "1.4.2"

end

