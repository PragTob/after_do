# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'after_do/version'

Gem::Specification.new do |spec|
  spec.name          = "after_do"
  spec.version       = AfterDo::VERSION
  spec.authors       = ["Tobias Pfeiffer"]
  spec.email         = ["pragtob@gmail.com"]
  spec.description   = %q{after_do is a gem that let's you execute a block of your choice after a specific method was called on a class.}
  spec.summary       = %q{after_do allows you to do simple after hooks on methods}
  spec.homepage      = "https://github.com/PragTob/after_do"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
