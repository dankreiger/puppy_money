require 'active_support/core_ext/object/try'
require_relative 'currencies'
require_relative 'rate_api'

class Money
  attr_reader :amount, :base_currency

  # use options for custom currency conversion
  def initialize amount, base_currency, options={}
    validate_input amount, base_currency, options
  end


  private

  def validate_input(amount, base_currency, options)
    raise ArgumentError, "Amount must be a number" unless amount.is_a? Numeric
    raise ArgumentError, base_currency_error(base_currency) if options.empty? && !RateApi.fetch_symbols.include?(base_currency)
    raise ArgumentError, base_currency_error(base_currency) if !options.empty? && base_currency.try(:upcase) && !Currencies.abbreviations.include?(base_currency.try(:upcase))
  end

  def base_currency_error(base_currency)
    " `#{base_currency}` is an invalid (currency abbreviation must be a recognized 3 character string)"
  end
end
