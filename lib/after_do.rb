# frozen_string_literal: true

# The after_do library adds callbacks to methods in Ruby. Before using this
# with any class, said class has to extend the AfterDo module first e.g.
#    MyClass.extend AfterDo
#    MyClass.after :some_method do awesome_stuff end
#
# More information at the github page: https://github.com/PragTob/after_do
module AfterDo
  # The prefix for the copies of the original methods made by after_do
  ALIAS_PREFIX = '__after_do_orig_'

  # Raised when trying to attach a callback to a non existing method
  class NonExistingMethodError < StandardError ; end

  # Raised when an error occurs in one of the callbacks of a method. Provides
  # additional information such as which method and where the block was
  # defined.
  class CallbackError < StandardError ; end

  module Core
    private
    def _after_do_define_callback(type, methods, block)
      @_after_do_callbacks ||= _after_do_basic_hash
      methods = methods.flatten # in case someone used an Array
      _after_do_raise_no_method_specified(type) if methods.empty?
      methods.each do |method|
        _after_do_add_callback_to_method(type, method, block)
      end
    end

    def _after_do_raise_no_method_specified(type)
      raise ArgumentError, "#{type} takes at least one method name!"
    end

    def _after_do_basic_hash
      {after: _after_do_methods_hash, before: _after_do_methods_hash}
    end

    def _after_do_methods_hash
      Hash.new {|hash, key| hash[key] = []}
    end

    def _after_do_add_callback_to_method(type, method, block)
      alias_name = _after_do_aliased_name method
      _after_do_redefine(method, alias_name) unless _after_do_redefined?(alias_name)
      @_after_do_callbacks[type][method] << block
    end

    def _after_do_redefined?(alias_name)
      private_instance_methods(false).include? alias_name
    end

    def _after_do_redefine(method, alias_name)
      _after_do_raise_no_method_error(method) unless _after_do_defined?(method)
      _after_do_rename_old_method(method, alias_name)
      _after_do_redefine_method_with_callback(method, alias_name)
    end

    def _after_do_defined?(method)
      method_defined?(method) || private_method_defined?(method)
    end

    def _after_do_raise_no_method_error(method)
      raise NonExistingMethodError, "There is no method #{method} on #{self} to attach a block to with after_do"
    end

    def _after_do_aliased_name(symbol)
      (ALIAS_PREFIX + symbol.to_s).to_sym
    end

    def _after_do_rename_old_method(old_name, new_name)
      alias_method new_name, old_name
      private new_name
    end

    def _after_do_redefine_method_with_callback(method, alias_name)
      callback_klazz = self
      define_method method do |*args|
        callback_klazz.send(:_after_do_execute_before_callbacks, method, self, *args)
        return_value = send(alias_name, *args)
        callback_klazz.send(:_after_do_execute_after_callbacks, method, self, *args, return_value)
        return_value
      end
    end

    def _after_do_execute_before_callbacks(method, object, *args)
      _after_do_each_callback_wrapped(:before, method) do |callback|
        callback.call(*args, method, object)
      end
    end

    def _after_do_execute_after_callbacks(method, object, *args, return_value)
      _after_do_each_callback_wrapped(:after, method) do |callback|
        callback.call(*args, method, return_value, object)
      end
    end

    def _after_do_each_callback_wrapped(type, method)
      @_after_do_callbacks[type][method].each do |block|
        begin
          yield block
        rescue Exception => error
          raise CallbackError, "#{error.class}: #{error.message} raised during an after_do callback block for method '#{method}' on the instance #{self.inspect} defined in the file #{block.source_location[0]} in line #{block.source_location[1]}.\n This is the backtrace of the original error: \n #{error.backtrace.join("\n")}"
        end
      end
    end

    def _after_do_remove_all_callbacks
      @_after_do_callbacks = _after_do_basic_hash
    end
  end

  include Core
  # A method to add a callback to a method or a list of methods to be executed
  # after the original method was executed. E.g.:
  #    MyClass.after :some_method do awesome_stuff end
  # It can only take a list of methods after which a block should be executed:
  #    MyClass.after :method1, :method2, :method3 do puts 'jay!' end
  # The list can also be an Array.
  def after(*methods, &block)
    _after_do_define_callback(:after, methods, block)
  end

  # This method works much like .after - except blocks are executed
  # before the method is called.
  def before(*methods, &block)
    _after_do_define_callback(:before, methods, block)
  end

  # Removes all callbacks attached to methods in the module.
  def remove_all_callbacks
    _after_do_remove_all_callbacks
  end

  # Methods in here do exactly the same as their siblings above, with the minor
  # difference that their names are prefixed with `ad_` to avoid naming clashes.
  module AlternativeNaming
    include Core

    def ad_after(*methods, &block)
      _after_do_define_callback(:after, methods, block)
    end

    def ad_before(*methods, &block)
      _after_do_define_callback(:before, methods, block)
    end

    def ad_remove_all_callbacks
      _after_do_remove_all_callbacks
    end
  end
end
