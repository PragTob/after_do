module AfterDo
  ALIAS_PREFIX = '__after_do_orig_'

  def self.extended(klazz)
    klazz.send(:include, AfterDo::Instance)
    klazz.send(:extend, AfterDo::Class)
  end

  class NonExistingMethodError < StandardError ; end
  class CallbackError < StandardError ; end

  module Class

    def _after_do_callbacks
      @_after_do_callbacks || _after_do_basic_hash
    end

    def after(*methods, &block)
      _after_do_define_callback(:after, methods, block)
    end

    def before(*methods, &block)
      _after_do_define_callback(:before, methods, block)
    end

    def remove_all_callbacks
      @_after_do_callbacks = _after_do_basic_hash if @_after_do_callbacks
    end

    private
    def _after_do_define_callback(type, methods, block)
      @_after_do_callbacks ||= _after_do_basic_hash
      methods.flatten! #in case someone used an Array
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
      unless _after_do_method_already_renamed?(method)
        _after_do_make_after_do_version_of_method(method)
      end
      @_after_do_callbacks[type][method] << block
    end

    def _after_do_make_after_do_version_of_method(method)
      _after_do_raise_no_method_error(method) unless _after_do_defined?(method)
      alias_name = _after_do_aliased_name method
      _after_do_rename_old_method(method, alias_name)
      _after_do_redefine_method_with_callback(method, alias_name)
    end

    def _after_do_defined?(method)
      method_defined?(method) || private_method_defined?(method)
    end

    def _after_do_raise_no_method_error(method)
      raise NonExistingMethodError, "There is no method #{method} on #{self} to attach a block to with AfterDo"
    end

    def _after_do_aliased_name(symbol)
      (ALIAS_PREFIX + symbol.to_s).to_sym
    end

    def _after_do_rename_old_method(old_name, new_name)
      class_eval do
        alias_method new_name, old_name
        private new_name
      end
    end

    def _after_do_redefine_method_with_callback(method, alias_name)
      class_eval do
        define_method method do |*args|
          _after_do_execute_callbacks :before, method, *args
          return_value = send(alias_name, *args)
          _after_do_execute_callbacks :after, method, *args
          return_value
        end
      end
    end

    def _after_do_method_already_renamed?(method)
      private_method_defined? _after_do_aliased_name(method)
    end
  end

  module Instance
    def _after_do_execute_callbacks(type, method, *args)
      callback_classes = self.class.ancestors.select do |klazz|
        _after_do_has_callback_for?(klazz, type, method)
      end
      callback_classes.each do |klazz|
        klazz._after_do_callbacks[type][method].each do |block|
          _after_do_execute_callback(block, method, *args)
        end
      end
    end

    def _after_do_has_callback_for?(klazz, type, method)
      klazz.respond_to?(:_after_do_callbacks) &&
        klazz._after_do_callbacks[type][method]
    end

    def _after_do_execute_callback(block, method, *args)
      begin
        block.call *args, self
      rescue Exception => error
        raise CallbackError, "A callback block for method #{method} on the instance #{self} with the following arguments: #{args.join(', ')} defined in the file #{block.source_location[0]} in line #{block.source_location[1]} resulted in the following error: #{error.class}: #{error.message} and this backtrace:\n #{error.backtrace.join("\n")}"
      end
    end
  end
end