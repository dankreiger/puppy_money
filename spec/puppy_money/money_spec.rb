require "spec_helper"

describe Money do
  context "validate_input" do
    let(:error_msg){ 'Amount must be a number' }
    let(:strings)  { ['puppy', '50', '50.000' 'Duzentilliarden'] }
    let(:booleans) { [true, false, nil] }
    let(:symbols)  { [:hi, :bye] }
    let(:arrays)   { [strings, booleans, symbols] }
    let(:hashes)   { [Hash.new, {}, {foo: 'bar'}] }
    let(:numbers)  { [50, 50.01, 50.011] }

    it "amount must be numerical" do
      ## invalid data types
      strings.each  { |str|  expect{ Money.new str,  'EUR' }.to raise_error ArgumentError, error_msg }
      booleans.each { |bool| expect{ Money.new bool, 'EUR' }.to raise_error ArgumentError, error_msg }
      symbols.each  { |sym|  expect{ Money.new sym,  'EUR' }.to raise_error ArgumentError, error_msg }
      arrays.each   { |arr|  expect{ Money.new arr,  'EUR' }.to raise_error ArgumentError, error_msg }
      hashes        { |hash| expect{ Money.new hash, 'EUR' }.to raise_error ArgumentError, error_msg }

      # valid data types
      numbers.each { |num| expect{ Money.new num, 'EUR' }.to_not raise_error }
    end
  end
end
