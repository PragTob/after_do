require 'after_do'

module M
  def method
  end
end

class A
  include M
end

class B
  include M
end

class C
  include M

  def method
    puts 'Overridden method'
  end
end

class D
  prepend M

  def method
    puts 'Wanna be Overriden method'
  end
end

M.extend AfterDo
M.after :method do puts 'method called' end

A.new.method
B.new.method

# won't call callback since the implementation was overriden
C.new.method

# will call callback since the module extending AfterDo was prepended
D.new.method

# Output is:
# method called
# method called
# Overridden method
# method called
