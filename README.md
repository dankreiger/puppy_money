# PuppyMoney [![Build Status](https://travis-ci.org/dankreiger/puppy_money.svg?branch=master)](https://travis-ci.org/dankreiger/puppy_money)

Convert money using real-time exchange rates from [fixer.io](http://fixer.io/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puppy_money'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install puppy_money

## Usage
Woof.

Conversion money using real-time rates
```ruby
# Instantiate money objects:

fifty_eur = Money.new(50, 'EUR')

# Get amount and currency:

fifty_eur.amount   # => 50
fifty_eur.currency # => "EUR"
fifty_eur.inspect  # => "50.00 EUR"

# Convert to a different currency with up to date exchange rates

# exchange rate April 26, 2017
fifty_eur.convert_to('USD') # => 54.46 USD

# Perform operations in different currencies:

## Arithmetic

fifty_eur + twenty_dollars # => 68.02 EUR
fifty_eur - twenty_dollars # => 31.98 EUR
fifty_eur / 2              # => 25 EUR
twenty_dollars * 3         # => 60 USD

## Comparisons (also in different currencies):

twenty_dollars == Money.new(20, 'USD') # => true
twenty_dollars == Money.new(30, 'USD') # => false

fifty_eur_in_usd = fifty_eur.convert_to('USD')
fifty_eur_in_usd == fifty_eur          # => true

twenty_dollars > Money.new(5, 'USD')   # => true
twenty_dollars < fifty_eur             # => true
```

## TODO
Implement functionality for manually inputted currencies and non-standard currencies

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dankreiger/puppy_money. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
