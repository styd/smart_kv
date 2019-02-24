class SmartKv
  InitializationError = Class.new(StandardError)

  class KeyError < ::StandardError
    attr_reader :key, :receiver

    def initialize(message, key: nil, receiver: {})
      @key = key
      @receiver = receiver
      super(message)
    end
  end
end
