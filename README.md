*Under Development*

This project is under active development, so be prepared for APIs to just break until we get to a
more stable version number.

# Atacama

[![Build Status](https://travis-ci.org/fulcrumapp/atacama.svg?branch=master)](https://travis-ci.org/fulcrumapp/atacama)

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

```ruby
class UserFetcher < Atacama::Contract
  option :id, Types::Strict::Number.gt(0)
  returns Types.Instance(User)

  def call
    User.find(id)
  end
end

UserFetcher.call(id: 1)
```

With the use of two classes, we can compose together multiple Contracts to yield a pipeline
of changes to execute.

```ruby
class UserFetcher < Atacama::Step
  option :id, type: Types::Strict::Number.gt(0)
  returns Types.Option(model: Types.Instance(User))

  # Both #Option and #Return are flow control values that tell the transaction what is a
  # value object and what should halt execution and return.
  def call
    Option(model: User.find!(id))
  rescue ActiveRecord::RecordNotFound
    Return(Error.new('Not found'))
  end
end

# Around steps allow for yielding to child steps for things like instrumentation or
# ActiveRecord::Transactions.
class Duration < Atacama::Step
  def call
    start = Time.now
    yield
    $redis.avg('duration', Time.now - start)
  end
end

# The transaction class descends the queue of steps, yielding options to each step
# defined.
#
# Steps can be defined with:
#   * Procs
#   * Class references
#   * Instance methods
#
class UpdateUser < Atacama::Transformer
  option :id, type: Types::Strict::Number.gt(0)
  option :attributes, type: Types::Strict::Hash

  returns_option :model, Types.Instance(User) | Types.Instance(Error)

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

```ruby
UpdateUser.new(steps: {
  save: lambda do
    puts "skipping save"
  end
})
```

Sometimes you need to compose these objects together and inject dependencies. Those injected values
will be passed in to the object when it's later invoked with `#call`.

```ruby
UpdateUser.inject(id: 1).call(attributes: { email: 'hello@world.com' })
```

Injected contracts can then be used inside of a Contract. Useful for Polymorphic objects.

```ruby
class HistoryCreate < Atacama::Step
  option :history_class, type: Types::Strict::Class
  option :model, type: Types.Instance(ActiveRecord::Base)

  def call
    history_class.from_model(model)
  end
end

class UpdateUser < Atacama::Transformer
  option :id, type: Types::Strict::Number.gt(0)
  option :attributes, type: Types::Strict::Hash

  returns_option :model, Types.Instance(User) | Types.Instance(Error)

  step :duration, with: Duration do
    step :find, with: UserFetcher
    step :save, with: Saver
    step :history, with: HistoryCreate.inject(history_class: UserHistory)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fulcrumapp/atacama.
