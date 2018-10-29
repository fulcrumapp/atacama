# Atacama

Atacama aims to attack the issue of Service Object patterns in a way that focuses on reusing logic
and ease of testability.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atacama'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atacama

## Usage

The basic object is `Contract`. It enforces type contracts by utilizing `dry-types`.

```
class UserFetcher < Atacama::Contract
  option :id, Types::Strict::Number.gt(0)

  def call
    User.find(id)
  end
end

UserFetcher.call(id: 1)
```

With the use of two classes, we can compose together multiple Contracts to yield a pipeline
of changes to execute.

```
class UserFetcher < Atacama::Step
  option :id, type: Types::Strict::Number.gt(0)

  def call
    Option(model: User.find(id))
  end
end

class Duration < Atacama::Step
  def call
    start = Time.now
    yield
    $redis.avg('duration', Time.now - start)
  end
end

class UpdateUser < Atacama::Transformer
  option :model, type: Types::Instance(User)
  option :attributes, type: Types::Strict::Hash

  step :duration, with: Duration do
    step :find, with: UserFetcher
    step :save
  end

  private

  def save
    context.model.update_attributes(attributes)
  end
end

UpdateUser.call(id: 1, attributes: {
  email: 'hello@world.com'
})
```

Any step can be mocked out without the need for a third party library. Just pass any object that
responds to `#call` in the class initializer.

```
UpdateUser.new(steps: {
  save: lambda do |**|
    puts "skipping save"
  end
})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fulcrumapp/atacama.
