require File.expand_path('../../lib/after_do', __FILE__)

class Dog
  def bark
    puts 'Woooof'
  end

  def eat
    puts 'yummie!'
  end
end

Dog.extend AfterDo
Dog.after :bark do puts 'I just heard a dog bark!' end

dog = Dog.new
dog2 = Dog.new

dog.bark
dog.eat
dog2.bark