def has_did_you_mean_key_error?
  !ENV['TRAVIS'] && Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.5.0") && defined?(DidYouMean)
end

require_relative "smart_kv/version"
require_relative "smart_kv/register"
require_relative "smart_kv/errors"

if has_did_you_mean_key_error?
  require_relative "smart_kv/did_you_mean"
end

class SmartKv
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
end
