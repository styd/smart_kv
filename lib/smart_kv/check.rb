module SmartKv::Check
  def has_did_you_mean_key_error?
    !ENV['TRAVIS'] &&
      Gem::Version.new(RUBY_VERSION) > Gem::Version.new("2.5.0") &&
      defined?(DidYouMean)
  end
  module_function :has_did_you_mean_key_error?

  def production?
    (ENV['RAILS_ENV'] || ENV['RACK_ENV']) == "production"
  end
  module_function :production?
end
