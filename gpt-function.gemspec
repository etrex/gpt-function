# frozen_string_literal: true

require_relative "lib/gpt_function/version"

Gem::Specification.new do |spec|
  spec.name = "gpt-function"
  spec.version = GptFunction::VERSION
  spec.authors = ["etrex kuo"]
  spec.email = ["et284vu065k3@gmail.com"]

  spec.summary = "A Ruby gem for creating simple GPT-based functions."
  spec.description = "This gem allows users to create simple and complex GPT functions " \
                   "for various applications such as translation and keyword extraction."
  spec.homepage = "https://github.com/etrex/gpt-function"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency "dotenv"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
