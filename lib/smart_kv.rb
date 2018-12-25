require "smart_kv/version"
require "smart_kv/register"
require "smart_kv/macro"

SmartKvInitializationError = Class.new(StandardError)

class SmartKv
  extend Register
  extend Macro

  attr_reader :object_class

  def initialize(required_keys = [], optional_keys = [], object_class = nil, kv = {})
    prevent_direct_instantiation

    @object_class = object_class || kv.class
    @kv = kv.dup

    if @object_class.respond_to?(:members) && @object_class.members != @kv.to_h.keys
      raise ArgumentError, "#{ @object_class } struct size differs"
    end

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
    @object ||= if @object_class == Struct
                  Struct.new(*@kv.to_h.keys).new(*@kv.to_h.values)
                elsif @object_class < Struct
                  @object_class.new(*@kv.to_h.values)
                elsif @object_class <= Hash
                  @kv
                else
                  @object_class.new(@kv.to_h)
                end
    @object.send(m, *args)
  end

protected

  def prevent_direct_instantiation
    if self.class == SmartKv
      raise SmartKvInitializationError, "only subclass of SmartConfig can be instantiated"
    end
  end
end
