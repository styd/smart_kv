module SmartKv::Register
  def required(*args)
    @required ||= superclass == SmartKv ? Set.new : superclass.required_keys.dup
    @required += args
  end

  def required_keys
    @required.to_a
  end

  def optional(*args)
    @optional ||= superclass == SmartKv ? Set.new : superclass.optional_keys.dup
    @optional += args
    @required -= @optional
    @optional
  end

  def optional_keys
    @optional.to_a
  end

  def new(*args)
    super(@required.to_a, @optional.to_a, @callable_as, *args)
  end
end
