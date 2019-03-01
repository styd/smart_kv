module SmartKv::Check
  def has_did_you_mean_key_error?
    !ENV['TRAVIS'] && defined?(DidYouMean::KeyErrorChecker)
  end
  module_function :has_did_you_mean_key_error?

  def production?
    (ENV['RAILS_ENV'] || ENV['RACK_ENV']) == "production"
  end
  module_function :production?
end
