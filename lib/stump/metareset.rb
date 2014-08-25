class Object
  def safe_meta_def method_name, &method_body
    metaclass.remember_original_method(method_name)
    meta_eval {
      define_method(method_name) {|*args, &block|
        method_body.call(*args, &block)
      }
    }
  end

  def reset(method_name, opts = {})
    metaclass.restore_original_method(method_name, opts)
  end

  protected

  def remember_original_method(method_name, opts = {})
    alias_method "__original_#{method_name}".to_sym, method_name if method_defined?(method_name)
    self
  end

  def restore_original_method(method_name, opts = {})
    original_method_name = "__original_#{method_name}".to_sym
    if method_defined?(original_method_name)
      alias_method method_name, original_method_name
      remove_method(original_method_name) unless opts.delete(:keep_method)
    end
    self
  end
end
