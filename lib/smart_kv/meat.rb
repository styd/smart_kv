require_relative "errors"
require_relative "convert"

module SmartKv::Meat
  # The meat of the gem

  include SmartKv::Convert

  def required(*args)
    @required ||= superclass == SmartKv ? Set.new : superclass.required_keys.dup
    @required += args
    @optional -= @required if @optional
    @required
  end

  def required_keys
    @required.to_a
  end

  def optional(*args)
    @optional ||= superclass == SmartKv ? Set.new : superclass.optional_keys.dup
    @optional += args
    @required -= @optional if @required
    @optional
  end

  def optional_keys
    @optional.to_a
  end

  def keys
    Array(@required) + Array(@optional)
  end

  def check(kv={})
    prevent_direct_instantiation

    object_class = callable_class || kv.class
    kv = kv.dup

    unless SmartKv::Check.production?
      required_keys = Array(@required)
      optional_keys = Array(@optional)

      hash = kv.to_h
      missing_keys = required_keys - hash.keys
      unless missing_keys.empty?
        raise SmartKv::KeyError, "missing required key(s): #{missing_keys.map{|k| k.to_sym.inspect }.join(', ')} in #{self.class}"
      end

      unrecognized_keys = hash.keys - required_keys - optional_keys
      unless unrecognized_keys.empty?
        key = unrecognized_keys.first
        raise SmartKv::KeyError.new("key not found: #{key.inspect}.", key: key, receiver: (keys - hash.keys).map {|k| [k, nil] }.to_h)
      end
    end

    return to_callable_object(object_class, kv)
  end
  alias_method :new, :check

  def callable_as(klass)
    @callable_as = superclass == SmartKv ? klass : superclass.callable_class
  end

  def callable_class
    @callable_as
  end

private

  def prevent_direct_instantiation
    if self == SmartKv
      raise SmartKv::InitializationError, "only subclass of SmartConfig can be instantiated".freeze
    end
  end
end
