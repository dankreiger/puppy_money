require_relative 'currency_data'

module Currencies
  def self.abbreviations
    CURRENCIES.keys.map(&:to_s)
  end
end
