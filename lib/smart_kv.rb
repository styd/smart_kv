require_relative "smart_kv/version"
require_relative "smart_kv/check"
require_relative "smart_kv/meat"

class SmartKv
  if Check.has_did_you_mean_key_error?
    require_relative "smart_kv/did_you_mean"
  end

  extend Meat
end
