require "smart_kv/version"
require "smart_kv/register"

SmartKvInitializationError = Class.new(StandardError)

class SmartKv
  extend Register

  def initialize(required_keys = [], optional_keys = [], kv = {})
    prevent_direct_instantiation

    @kv = kv
    hash = kv.to_h.dup

    missing_keys = required_keys - hash.keys
    unless missing_keys.empty?
      raise KeyError, "missing required key(s): #{missing_keys.map{|k| "`:#{k}'" }.join(', ')} in #{self.class}"
    end

    unrecognized_keys = hash.keys - required_keys - optional_keys
    unless unrecognized_keys.empty?
      raise NotImplementedError, "unrecognized key(s): #{unrecognized_keys.map{|k| "`:#{k}'" }.join(', ')} in #{self.class}"
    end
  end

  def method_missing(m, *args)
    @kv.send(m, *args)
  end 

protected

  def prevent_direct_instantiation
    if self.class == SmartKv
      raise SmartKvInitializationError, "only subclass of SmartConfig can be instantiated"
    end
  end
end
