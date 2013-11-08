class NonExistingMethodError < StandardError ; end

module AfterDo
  ALIAS_PREFIX = '__after_do_orig_'

  def _after_do_callbacks
    @_after_do_callbacks || Hash.new([])
  end

  def after(*methods, &block)
    @_after_do_callbacks ||= Hash.new([])
    methods.flatten! #in case someone used an Array
    if methods.empty?
      raise ArgumentError, 'after takes at least one method name!'
    end
    methods.each do |method|
      if _after_do_method_already_renamed?(method)
        _after_do_make_after_do_version_of_method(method)
      end
      @_after_do_callbacks[method] << block
    end
  end

  def remove_all_callbacks
    @_after_do_callbacks = Hash.new([]) if @_after_do_callbacks
  end

  def _after_do_execute_callbacks_for(method, *args, instance)
    current_class = self
    while current_class.method_defined? method
      if current_class.respond_to? :_after_do_callbacks
        current_class._after_do_callbacks[method].each do |block|
          block. call *args, instance
        end
      end
      current_class = current_class.superclass
    end
  end

  private
  def _after_do_make_after_do_version_of_method(method)
    _after_do_raise_no_method_error(method) unless self.method_defined? method
    @_after_do_callbacks[method] = []
    alias_name = _after_do_aliased_name method
    _after_do_rename_old_method(method, alias_name)
    _after_do_redefine_method_with_callback(method, alias_name)
  end

  def _after_do_raise_no_method_error method
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
        return_value = send(alias_name, *args)
        self.class._after_do_execute_callbacks_for method, *args, self
        return_value
      end
    end
  end

  def _after_do_method_already_renamed?(method)
    !private_method_defined? _after_do_aliased_name(method)
  end
end