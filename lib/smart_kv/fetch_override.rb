module FetchOverride
  refine Hash do
    alias :original_fetch :fetch

    def fetch(key)
      original_fetch(key)
    rescue KeyError => e
      raise SmartKv::KeyError, e.message
    end
  end
end
