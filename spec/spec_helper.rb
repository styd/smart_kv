require 'coveralls'
Coveralls.wear!

require "bundler/setup"
require "ostruct"
require "smart_kv"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Swapping constants is for when I develop this gem along with other project that uses it.
# I don't want constants to clash when I run the specs together.
#
# For example:
#   bin/rspec spec/models/user_spec.rb ../smart_kv/spec/
#
# Maybe I'm overly cautious but better safe than sorry.
#
# def safely_swap_constant(original_constant_str)
#   if (klass = Object.const_get(original_constant_str) rescue nil)
#     Object.const_set("AVeryLongConstantToStore#{ original_constant_str }", klass)
#     Object.send(:remove_const, original_constant_str.to_sym)
#   end
# end
#
# def safely_swap_back_constant(original_constant_str)
#   Object.send(:remove_const, original_constant_str.to_sym)
#   if (klass = Object.const_get("AVeryLongConstantToStore#{ original_constant_str }") rescue nil)
#     Object.const_set(original_constant_str, klass)
#     Object.send(:remove_const, "AVeryLongConstantToStore#{ original_constant_str }".to_sym)
#   end
# end
#
# def safely_swap_all_constants(array_of_constant_str)
#   array_of_constant_str.each do |original_constant_str|
#     safely_swap_constant(original_constant_str)
#   end
# end
#
# def safely_swap_back_all_constants(array_of_constant_str)
#   array_of_constant_str.each do |original_constant_str|
#     safely_swap_back_constant(original_constant_str)
#   end
# end
