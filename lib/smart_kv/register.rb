module SmartKv::Register
  def required(*args)
    @required ||= self.superclass == SmartKv ? Set.new : superclass.required_keys.dup
    @required += args
  end

  def required_keys
    @required.to_a
  end

  def optional(*args)
    @optional ||= self.superclass == SmartKv ? Set.new : superclass.optional_keys.dup
    @optional += args
    @required -= @optional
    @optional
  end

  def optional_keys
    @optional.to_a
  end

  def new(*args)
    super(@required.to_a, @optional.to_a, *args)
  end
end
