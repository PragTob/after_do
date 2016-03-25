require 'simplecov'
require 'coveralls'
SimpleCov.formatters = [Coveralls::SimpleCov::Formatter,
                        SimpleCov::Formatter::HTMLFormatter]

SimpleCov.start do
  add_filter '/spec/'
end

require 'after_do'
