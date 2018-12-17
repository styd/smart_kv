module SmartKv::Macro
  def callable_as(klass)
    @callable_as = superclass == SmartKv ? klass : superclass.callable_class
  end

  def callable_class
    @callable_as
  end
end
