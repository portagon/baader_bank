# frozen_string_literal: true

require_relative 'lib/baader_bank/version'

Gem::Specification.new do |spec|
  spec.name     = 'baader_bank'
  spec.version  = BaaderBank::VERSION
  spec.authors  = ['Portagon GmbH']
  spec.email    = ['tech@portagon.com']
  spec.homepage = 'https://github.com/portagon/baader_bank'

  spec.summary = 'Ruby client for the Baader Bank Customer REST API'
  spec.description = <<~DESC
    Encapsulates authentication, error handling, and resource methods for the Baader Bank
    Customer API (accounts, orders, securities accounts, payments, and related resources).
  DESC

  spec.metadata['homepage_uri'] = spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['github_repo'] = 'ssh://github.com/portagon/baader_bank'

  spec.required_ruby_version = '~> 3.4'
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'faraday-multipart', '~> 1.0'
end
