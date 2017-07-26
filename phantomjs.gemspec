# -*- encoding: utf-8 -*-
require File.expand_path('../lib/phantomjs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christoph Olszowka"]
  gem.email         = ["christoph at olszowka.de"]
  gem.description   = %q{Auto-install phantomjs on demand for current platform. Comes with poltergeist integration.}
  gem.summary       = %q{Auto-install phantomjs on demand for current platform. Comes with poltergeist integration.}
  gem.homepage      = "https://github.com/colszowka/phantomjs-gem"
  gem.license       = 'MIT'

  gem.add_development_dependency 'poltergeist', '~> 1.5'
  gem.add_development_dependency 'capybara', '~> 2.4'
  gem.add_development_dependency 'rspec', "~> 2.99"
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rake'
  if RUBY_VERSION < '2'
    gem.add_development_dependency "mime-types", "~> 2.6"
    gem.add_development_dependency 'addressable', '~> 2.4.0'
  end
  if RUBY_VERSION < '2.1'
    gem.add_development_dependency "nokogiri", "~> 1.6.8.1"
  elsif RUBY_VERSION < '2.2'
    gem.add_development_dependency 'nokogiri', '~> 1.7.0'
  end
  if RUBY_VERSION < '2.2'
    gem.add_development_dependency "rack", "~> 1.6.7"
  end

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "phantomjs"
  gem.require_paths = ["lib"]
  gem.version       = Phantomjs::VERSION
end
