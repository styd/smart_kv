# SmartKv

Best practice of writing configurations by strictly allowing and requiring keys.

It doesn't have to be a configuration.
You can use it for strict request body or other use cases too.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_kv'
```

And then execute:

    $ bundle

## Usage

```ruby
class Config < SmartKv
  required :some_key, :second_key
  optional :an_option
end

Config.new({some_key: "val"})
```

This will complain that you're not using the `:second key`.
Guess what the `optional` do!

### Inheritable

```ruby
class ChildConfig < Config
  required :first_key
end

ChildConfig.new({first_key: "val", second_key: "val 2"})
```

This will also complain that you're not using the `:some_key`.

### Directly callable

Whatever given as input is callable directly.

```ruby
c = Config.new({some_key: "val", second_key: "val 2"})
c[:some_key]

c2 = Config.new(OpenStruct.new({some_key: "val", second_key: "val 2"}))
c2.second_key
```

### Not using it for config

You can choose not to use it for config. Maybe for strict request body keys?

```ruby
class PostBody < SmartKv
  required :app_key, :secret_key
end
.
.
request.set_form_data(PostBody.new({app_key: "abc", secret_key: "def"}))
```

## Coming Soon

- [ ] Make it serializable
- [ ] Convertable from hash (as input) to OpenStruct (the resulting object) or another object and vice versa
- [ ] Accept config file (e.g. `json`, `yaml`, etc.) or file path as input
- [ ] Support nested/deep key value object as input
- [ ] Make some nested keys from the same parent key required and some others optional

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/styd/smart_kv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SmartKv project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/styd/smart_kv/blob/master/CODE_OF_CONDUCT.md).
