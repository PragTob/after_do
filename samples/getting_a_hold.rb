require 'after_do'

class Example
  def zero
    # ...
  end

  def two(a, b)
    # ...
  end

  def value
    'some value'
  end
end

Example.extend AfterDo

Example.after :zero do puts 'Hello!' end

# If the callback method takes no arguments then the first argument passed to
# the block with will the instance of the class on which the original method
# is called:
Example.after :zero do |obj| puts obj.value end

# The method arguments are passed to the callback as well:
Example.after :two do |first, second| puts first + ' ' + second end

# If the callback takes arguments, the last argument will be the instance of the
# class:
Example.after :two do |a, b, obj| puts a + ' ' + b + ' ' + obj.value end

# You can also use the * to soak up all the method arguments and get
# straight to the instance:
Example.after :two do |*args, obj|
  puts "args passed to callback: #{args.join(', ')}"
  puts 'just ' +  obj.value
end

e = Example.new
e.zero
e.two 'one', 'two'
# prints:
# Hello!
# some value
# one two
# one two some value
# args passed to callback: one, two
# just some value
