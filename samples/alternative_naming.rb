require 'after_do'

class MyClashingClass
  extend AfterDo::AlternativeNaming

  def foo
    42
  end

  def self.after
    nil
  end

  def self.before
    nil
  end
end

MyClashingClass.ad_after :foo do puts 'it works' end
MyClashingClass.new.foo

module MyOwnAfterDo
  include AfterDo::Core

  def later(*methods, &block)
    _after_do_define_callback(:after, methods, block)
  end

  def earlier(*methods, &block)
    _after_do_define_callback(:before, methods, block)
  end

  def forget_it_all
    _after_do_remove_all_callbacks
  end
end

class MyOtherClashingClass
  extend MyOwnAfterDo

  def foo
    42
  end

  def self.after
    nil
  end

  def self.before
    nil
  end
end

MyOtherClashingClass.later :foo do puts 'my own works' end
MyOtherClashingClass.earlier :foo do puts 'my own earlier works' end
MyOtherClashingClass.new.foo
