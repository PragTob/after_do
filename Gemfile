source 'https://rubygems.org'

gemspec

gem 'bundler'
gem 'rake'
gem 'rspec'
gem 'simplecov'
gem "codeclimate-test-reporter"
gem 'rdoc'

RUBY_2 = /^2\./
unless RUBY_VERSION =~ RUBY_2
  # json 2 seems to be broken old rubies
  gem 'json', '< 2'
end
