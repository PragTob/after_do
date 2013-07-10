module AfterDo
  ALIAS_PREFIX = '__after_do_orig_'

  def _after_do_callbacks
    @_after_do_callbacks
  end

  def after(*methods, &block)
    @_after_do_callbacks ||= Hash.new([])
    methods.flatten! #in case someone used an Array
    if methods.empty?
      raise ArgumentError, 'after takes at least one method name!'
    end
    methods.each do |method|
      make_after_do_version_of_method(method) if method_already_renamed?(method)
      @_after_do_callbacks[method] << block
    end
  end

  def remove_all_callbacks
    if @_after_do_callbacks
      @_after_do_callbacks.keys.each do |key| @_after_do_callbacks[key] = [] end
    end
  end

  private

  def make_after_do_version_of_method(method)
    @_after_do_callbacks[method] = []
    alias_name = aliased_name method
    rename_old_method(method, alias_name)
    redefine_method_with_callback(method, alias_name)
  end

  def aliased_name(symbol)
    (ALIAS_PREFIX + symbol.to_s).to_sym
  end

  def rename_old_method(old_name, new_name)
    class_eval do
      alias_method new_name, old_name
      private new_name
    end
  end

  def redefine_method_with_callback(method, alias_name)
    class_eval do
      define_method method do |*args|
        return_value = send(alias_name, *args)
        self.class._after_do_callbacks[method].each do |block|
          block.call *args, self
        end
        return_value
      end
    end
  end

  def method_already_renamed?(method)
    !private_method_defined? aliased_name(method)
  end
end