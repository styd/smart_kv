# SmartKv

[![Build Status](https://travis-ci.org/styd/smart_kv.svg?branch=master)](https://travis-ci.org/styd/smart_kv)
[![Coverage Status](https://coveralls.io/repos/github/styd/smart_kv/badge.svg?branch=master)](https://coveralls.io/github/styd/smart_kv?branch=master)
[![Gem Version](https://badge.fury.io/rb/smart_kv.svg)](https://rubygems.org/gems/smart_kv)

Best practice of writing options or configurations by strictly allowing and requiring keys.

It doesn't have to be options or configurations.
You can use it for strict request body or other use cases too.

## Background

Have you ever used ruby options like this:

```ruby
# this example is for rails
d = DateTime.now
e = d.change(hour: 1, minute: 5)
```

and then move on with your life.. until you realize that the code doesn't behave as you expected it to behave.  
But why? Everything looks fine, right? Yes, it does look fine.. but it's not fine.  

So, what's the problem?  
The problem was the option key `:minute` was not recognized.  
Eh? :confused:  
Why didn't it tell me if it was not recognized?  

I wish that too.  
But `Hash` has a default value of `nil` if key is not found (same thing applies to `OpenStruct`) - so, it will not raise error -
and most developers won't bother checking each options' key made by the users of the library or method.  

If only the source of the `DateTime#change` method starts like this:

```ruby
# this class can be defined on its own file
class ChangeOptions < SmartKv
  optional :nsec, :usec, :year, :month, :day, :hour, :min, :sec, :offset, :start
end

class DateTime
...
  def change(options)
    options = ChangeOptions.new(options)
    ...
  end
end
```

So, when you do this `d.change(hour: 1, minute: 5)`, it will yell:

```
NotImplementedError: unrecognized key(s): `:minute' in ChangeOptions
```

Well, this is better. But, how do you know all the right options?  
Type: `ChangeOptions.optional_keys` and `ChangeOptions.required_keys`.


## More Usage Example

```ruby
class Config < SmartKv
  required :some_key, :second_key
  optional :an_option
end

Config.new({some_key: "val"})
```

This will complain that you're not using the `:second key`.
If you add another key that is not recognized, it will complain too.
If there is a key that you don't always use but want it to be recognized, mark it as `optional`.


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


### Override callable object

You can change the callable object to any class that accepts hash as input of its new class method.

```ruby
class Convertable < SmartKv
  required :abcd
  callable_as OpenStruct
end

c = Convertable.new({abcd: 123})
c.abcd #=> 123
```


### Not using it for options or configs?

You can choose not to use it for options or configs. Maybe for strict request body keys?

```ruby
class PostBody < SmartKv
  required :app_key, :secret_key
end
.
.
request.set_form_data(PostBody.new({app_key: "abc", secret_key: "def"}))
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_kv'
```

And then execute:

    $ bundle


## Coming Soon

- [X] Convertable from hash (as input) to OpenStruct (the resulting object) or another object and vice versa
- [ ] Suggests corrections for unrecognized keys using DidYouMean (and maybe change the spell checking threshold?)
- [ ] Support nested/deep key value object as input
- [ ] Make some nested keys from the same parent key required and some others optional
- [ ] Accept config file (e.g. `json`, `yaml`, etc.) or file path as input


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/styd/smart_kv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


## Code of Conduct

Everyone interacting in the SmartKv project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/styd/smart_kv/blob/master/CODE_OF_CONDUCT.md).
