module RateApi
  def self.fetch_symbols
    res = HTTParty.get 'http://api.fixer.io/latest'
    res['rates'].keys << res['base']
  end
end
