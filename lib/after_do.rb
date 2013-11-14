module AfterDo

  class NonExistingMethodError < StandardError ; end
  class CallbackError < StandardError ; end

  ALIAS_PREFIX = '__after_do_orig_'

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

  def _after_do_execute_callbacks(type, method, instance, *args)
    current_class = self
    while current_class.method_defined? method
      if current_class.respond_to? :_after_do_callbacks
        current_class._after_do_callbacks[type].fetch(method, []).each do |block|
          _after_do_execute_callback(block, instance, method, *args)
        end
      end
      current_class = current_class.superclass
    end
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
    {before: {}, after: {}}
  end

  def _after_do_add_callback_to_method(type, method, block)
    unless _after_do_method_already_renamed?(method)
      _after_do_make_after_do_version_of_method(method)
    end
    @_after_do_callbacks[type][method] << block
  end

  def _after_do_make_after_do_version_of_method(method)
    _after_do_raise_no_method_error(method) unless method_defined? method
    @_after_do_callbacks[:before][method] = []
    @_after_do_callbacks[:after][method] = []
    alias_name = _after_do_aliased_name method
    _after_do_rename_old_method(method, alias_name)
    _after_do_redefine_method_with_callback(method, alias_name)
  end

  def _after_do_raise_no_method_error(method)
    raise NonExistingMethodError,
          "There is no method #{method} on #{self} to attach a block to with AfterDo"
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
        self.class._after_do_execute_callbacks :before, method, self, *args
        return_value = send(alias_name, *args)
        self.class._after_do_execute_callbacks :after, method, self, *args
        return_value
      end
    end
  end

  def _after_do_method_already_renamed?(method)
    private_method_defined? _after_do_aliased_name(method)
  end

  def _after_do_execute_callback(block, instance, method, *args)
    begin
      block.call *args, instance
    rescue Exception => error
      raise CallbackError, "A callback block for method #{method} on the instance #{instance} with the following arguments: #{args.join(', ')} defined in the file #{block.source_location[0]} in line #{block.source_location[1]} resulted in the following error: #{error.class}: #{error.message} and this backtrace:\n #{error.backtrace.join("\n")}"
    end
  end
end