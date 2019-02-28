module SmartKv::Register
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

  def new(*args)
    prevent_direct_instantiation

    if SmartKv::Check.production?
      SmartKv::Convert.to_callable_object(callable_class, args.shift)
    else
      super(@required.to_a, @optional.to_a, callable_class, *args)
    end
  end

  def callable_as(klass)
    @callable_as = superclass == SmartKv ? klass : superclass.callable_class
  end

  def callable_class
    @callable_as
  end

  def prevent_direct_instantiation
    if self == SmartKv
      raise SmartKv::InitializationError, "only subclass of SmartConfig can be instantiated".freeze
    end
  end
end
