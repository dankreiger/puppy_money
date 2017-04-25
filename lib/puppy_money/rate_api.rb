require 'httparty'

module RateApi
  # needs refactoring!!!

  # get complete rate info
  def self.rate_request base_currency
    HTTParty.get "http://api.fixer.io/latest?base=#{base_currency}"
  end

  # get rate symbol abbreviations
  def self.fetch_symbols base_currency
    rate_info = self.rate_request base_currency
    rate_info['rates'].keys << rate_info['base']
  end

  # return a transfer rate
  def self.fetch_transfer_rate base_currency, transfer_currency
    xrates = self.rate_request base_currency
    xrates['rates'][transfer_currency]
  end
end
