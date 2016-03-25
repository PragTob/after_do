require 'after_do'

class Example
  def zero
    0
  end

  def two(a, b)
    a + b
  end

  def value
    'some_value'
  end
end

Example.extend AfterDo

Example.after :zero do puts 'Hello!' end

# If the callback method takes no arguments then the first argument passed to
# the block with will the method name, then the return value and finally the object itself
Example.after :zero do |_name, _return, obj| puts obj.value end

# The method arguments are passed to the callback as well:
Example.after :two do |first, second| puts "#{first} #{second}" end

# Now alltogether:
Example.after :two do |a, b, name, value, obj|
  puts "after: #{a} #{b} #{name} #{value} #{obj.value}"
end

# Remember before can't get a return value as at that point the method hasn't
# beene executed:
Example.before :two do |a, b, name, obj|
  puts "before: #{a} #{b} #{name} #{obj.value}"
end

# You can also use the * to soak up all the method arguments and get
# straight to the instance:
Example.after :two do |*args, _name, _return, obj|
  puts "args passed to callback: #{args.join(', ')}"
  puts 'just ' +  obj.value
end

e = Example.new
e.zero
e.two 1, 2
# prints:
# Hello!
# some value
# before: 1 2 two some_value
# 1 2
# after: 1 2 two 3 some_value
# args passed to callback: 1, 2
# just some value
