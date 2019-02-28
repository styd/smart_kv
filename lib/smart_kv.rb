require_relative "smart_kv/version"
require_relative "smart_kv/register"
require_relative "smart_kv/errors"
require_relative "smart_kv/check"
require_relative "smart_kv/convert"

class SmartKv
  if Check.has_did_you_mean_key_error?
    require_relative "smart_kv/did_you_mean"
  end

  extend Register

  attr_reader :object_class

  def initialize(required_keys = [], optional_keys = [], object_class = nil, kv = {})
    @object_class = object_class || kv.class
    @kv = kv.dup

    hash = kv.to_h
    missing_keys = required_keys - hash.keys
    unless missing_keys.empty?
      raise KeyError, "missing required key(s): #{missing_keys.map{|k| k.to_sym.inspect }.join(', ')} in #{self.class}"
    end

    unrecognized_keys = hash.keys - required_keys - optional_keys
    unless unrecognized_keys.empty?
      key = unrecognized_keys.first
      raise KeyError.new("key not found: #{key.inspect}.", key: key, receiver: (keys - hash.keys).map {|k| [k, nil] }.to_h)
    end
  end

  def keys
    Array(self.class.required) + Array(self.class.optional)
  end

  def method_missing(m, *args)
    @object ||= Convert.to_callable_object(@object_class, @kv)
    @object.send(m, *args)
  end
end
