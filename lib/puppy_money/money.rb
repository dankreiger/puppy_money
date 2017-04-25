require 'active_support/core_ext/object/try'
require_relative 'currencies'
require_relative 'rate_api'

class Money
  attr_reader :amount, :currency, :manual_currencies

  # use optional_rates for manual currency conversion
  def initialize amount, currency, manual_currencies={}
    validate_amount amount
    validate_currency currency.try(:upcase)

    # validate manual currency unless it is a non_standard currency (e.g. bitcoin)
    manual_currencies.each do |name, info|
      validate_currency name.to_s.upcase unless info[:non_standard]
    end

    @amount                  = amount.round(2)
    @currency                = currency.try(:upcase)
    @manual_currencies       = manual_currencies
  end

  def inspect
    "#{@amount} #{@currency}"
  end

  def convert_to transfer_currency, non_standard=false
    transfer_currency = transfer_currency.try(:upcase)
    # validate the transfer currency unless:
    ## 1. user explicitly specifies that it is a non-standard currency (e.g. bitcoin)
    validate_currency transfer_currency unless non_standard
    # use real-time exchange rates if:
    ## 1. user has not provided exchange rates manually
    ## 2  given transfer currency is not supported
    if @manual_currencies.empty? && RateApi.fetch_symbols(@currency).include?(transfer_currency)
      transfer_rate = RateApi.fetch_transfer_rate(@currency, transfer_currency)
      Money.new(@amount * transfer_rate, transfer_currency)
    end
  end

  #  money object arithmetic
  [:+, :-, :*, :/].each do |operation|
    define_method(operation) do |other|
      if @currency == other.currency
        Money.new(@amount.public_send(operation, other.amount), @currency)
      else
        # return an array with both money objects if the currencies are different
        [
          Money.new(@amount.public_send(operation, other.conversion_amount(@currency)), @currency),
          Money.new(self.conversion_amount(other.currency).public_send(operation, other.amount), other.currency)
        ]
      end
    end
  end

  def conversion_amount transfer_currency
    convert_to(transfer_currency).amount
  end

  private

  def validate_amount amount
    # ensure that the amount is a numeric value
    raise ArgumentError, "Amount must be a number" unless amount.is_a? Numeric
  end

  def validate_currency currency, manual_rates=false
    if manual_rates
      currency.map do |c|
        # raise an error if manual rate is not recognized
        raise ArgumentError, currency_error(currency) unless Currencies.abbreviations.include? c.to_s.upcase
      end
    else
      # raise an error if base rate is not recognized
      raise ArgumentError, currency_error(currency) unless Currencies.abbreviations.include?(currency)
    end
  end

  def currency_error(currency)
    " `#{currency}` is an invalid (currency abbreviation must be a recognized 3 character string)"
  end
end
