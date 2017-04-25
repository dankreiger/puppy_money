require 'active_support/core_ext/object/try'
require_relative 'currencies'
require_relative 'rate_api'

class Money
  attr_reader :amount, :base_currency

  def initialize amount, base_currency, options={}
    validate_input(
      amount: amount,
      base_currency: base_currency,
      options: options
    )
  end


  private

  def validate_input(**args)
    raise ArgumentError, "Amount must be a number" unless args[:amount].is_a? Numeric
    if !CURRENCIES.keys.map(&:to_s).include?(args[:base_currency])
      raise ArgumentError, " `#{args[:base_currency]}` is invalid (currency symbol must be a 3 character string)"
    end
  end
end
