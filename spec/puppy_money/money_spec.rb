require "spec_helper"

describe Money do

  describe "validate_input" do
    let(:amount_error)   { 'Amount must be a number' }
    let(:strings)        { ['puppy', '50', '50.000' 'Duzentilliarden'] }
    let(:booleans)       { [true, false, nil] }
    let(:symbols)        { [:hi, :bye] }
    let(:arrays)         { [strings, booleans, symbols] }
    let(:hashes)         { [Hash.new, {}, {foo: 'bar'}] }
    let(:numbers)        { [50, 50.01, 50.011] }
    let(:currencies)     { CURRENCIES.keys.map(&:to_s) }
    let(:api_currencies) { RateApi.fetch_symbols }

    context "amount" do
      it "must be numerical" do
        binding.pry
        # invalid amount
        strings.each    { |str|  expect{ Money.new str,  'EUR' }.to raise_error ArgumentError, amount_error }
        booleans.each   { |bool| expect{ Money.new bool, 'EUR' }.to raise_error ArgumentError, amount_error }
        symbols.each    { |sym|  expect{ Money.new sym,  'EUR' }.to raise_error ArgumentError, amount_error }
        arrays.each     { |arr|  expect{ Money.new arr,  'EUR' }.to raise_error ArgumentError, amount_error }
        hashes.each     { |hash| expect{ Money.new hash, 'EUR' }.to raise_error ArgumentError, amount_error }
        currencies.each { |currency| expect{ Money.new currency, 'EUR' }.to raise_error ArgumentError, amount_error }

        # valid amount
        numbers.each { |num| expect{ Money.new num, 'EUR' }.to_not raise_error }
      end
    end

    context "base_currency" do
      it "must be a valid currency symbol" do
        # invalid base_currency
        strings.each  { |str|  expect{ Money.new 50, str  }.to raise_error  ArgumentError }
        booleans.each { |bool| expect{ Money.new 50, bool }.to raise_error  ArgumentError }
        symbols.each  { |sym|  expect{ Money.new 50, sym  }.to raise_error  ArgumentError }
        arrays.each   { |arr|  expect{ Money.new 50, arr  }.to raise_error  ArgumentError }
        hashes.each   { |hash| expect{ Money.new 50, hash }.to raise_error  ArgumentError }

        # valid base_currency for automatic currency conversion
        api_currencies.each { |currency| expect{ Money.new 50, currency }.to_not raise_error }
        # valid base_currency for custom conversion
        currencies.each { |currency| expect{ Money.new 50, currency, {fake_currency: '0.4562'} }.to_not raise_error }
      end
    end
  end
end
