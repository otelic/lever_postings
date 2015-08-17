# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lever_postings/version'

Gem::Specification.new do |spec|
  spec.name          = "lever_postings"
  spec.version       = LeverPostings::VERSION
  spec.authors       = ["Sean Abrahams"]
  spec.email         = ["abrahams@gmail.com"]

  spec.summary       = %q(Ruby library for accessing Lever.co's Postings API)
  spec.description   = %q(Ruby library for accessing Lever.co's Postings API)
  spec.homepage      = "https://github.com/otelic/lever_postings"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 0.9"
  spec.add_dependency "multi_json", "~> 1.10"
  spec.add_dependency "hashie", ">= 2.1"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "webmock", "~> 1.21"
  spec.add_development_dependency "vcr", "~> 2.9"
end
