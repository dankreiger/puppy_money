require "spec_helper"

describe Money do

  describe "validations" do
    let(:amount_error)   { 'Amount must be a number' }
    let(:strings)        { ['puppy', '50', '50.000' 'Duzentilliarden'] }
    let(:booleans)       { [true, false, nil] }
    let(:symbols)        { [:hi, :bye] }
    let(:arrays)         { [strings, booleans, symbols] }
    let(:hashes)         { [Hash.new, {}, {foo: 'bar'}] }
    let(:numbers)        { [50, 50.01, 50.011] }
    let(:currencies)     { CURRENCIES.keys.map(&:to_s) }
    let(:api_currencies) { RateApi.fetch_symbols('EUR') }

    context "validate_amount" do
      it "must be numerical" do
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

    context "validate_currency" do
      it "must be a valid currency symbol" do
        # invalid currency
        strings.each  { |str|  expect{ Money.new 50, str  }.to raise_error  ArgumentError }
        booleans.each { |bool| expect{ Money.new 50, bool }.to raise_error  ArgumentError }
        symbols.each  { |sym|  expect{ Money.new 50, sym  }.to raise_error  ArgumentError }
        arrays.each   { |arr|  expect{ Money.new 50, arr  }.to raise_error  ArgumentError }
        hashes.each   { |hash| expect{ Money.new 50, hash }.to raise_error  ArgumentError }
        # invalid manually inputted currency
        currencies.each { |currency| expect{ Money.new 50, currency, {GBPP: {rate: '0.4562'}} }.to raise_error ArgumentError }
        currencies.each { |currency| expect{ Money.new 50, currency, {EURO: {rate: '0.4562'}, USD: {rate:  '1.1'}} }.to raise_error ArgumentError }
        currencies.each { |currency| expect{ Money.new 50, currency, {EURO: {rate: '0.4562'}, USD: {rate:  '1.1'},  Bitcoin: { rate: '0.0047', non_standard: true } } }.to raise_error ArgumentError }

        # valid currency for automatic currency conversion
        api_currencies.each { |currency| expect{ Money.new 50, currency }.to_not raise_error }
        # valid manually inputted currency
        currencies.each { |currency| expect{ Money.new 50, currency, {GBP: {rate: '0.4562'}} }.to_not raise_error }

        # do not raise an error for non-standard currencies
        currencies.each do |currency|
          expect{ Money.new 50, currency, { Bitcoin: { rate: '0.0047', non_standard: true } } }.to_not raise_error
          expect{ Money.new 50, currency, { Bitcoin: { rate: '0.0047', non_standard: true }, USD: {rate: '1.1'} } }.to_not raise_error
        end
      end
    end

    context "convert_to" do
      let(:money_euro) { Money.new 50, 'EUR' }
      let(:usd_rate)   { RateApi.fetch_transfer_rate(money_euro.currency, 'USD')  }

      # TODO: write a cleaner spec
      it "converts to a specified currency using real-time exchange rates" do
        expect((money_euro.convert_to('USD')).inspect).to eq Money.new(money_euro.amount * usd_rate, 'USD').inspect
      end
    end

    describe "money arithmetic" do
      let(:money_euro)  { Money.new 550.55, 'EUR' }
      let(:money_euro2) { Money.new 101.01, 'EUR' }
      let(:money_usd)   { Money.new 101.01, 'USD' }

      context "addition" do
        # TODO: write a cleaner spec
        it "returns the correct sum of amounts when adding money objects with the same currency" do
          sum = money_euro + money_euro2
          expect(sum.inspect).to eq Money.new(money_euro.amount + money_euro2.amount, 'EUR').inspect
          expect(sum.amount).to eq((550.55 + 101.01))
          expect(sum.currency).to eq 'EUR'
        end

        it "returns the correct sum of amounts when adding money objects with different currencies" do
          sum = money_euro + money_usd
          expect(sum.inspect).to eq [
            Money.new((money_euro.amount + money_usd.conversion_amount('EUR')), 'EUR'),
            Money.new((money_usd.amount + money_euro.conversion_amount('USD')), 'USD')
          ].inspect

          expect(sum.map(&:amount)).to eq [(money_euro.amount + money_usd.conversion_amount('EUR')).round(2), money_usd.amount + money_euro.conversion_amount('USD').round(2)]
          expect(sum.map(&:currency)).to eq ['EUR', 'USD']
        end

        it "returns the correct sum when adding money objects with a numeric" do
          sum = money_euro + 10
          expect(sum.inspect).to eq Money.new(money_euro.amount + 10, 'EUR').inspect
          expect(sum.amount).to eq((550.55 + 10))
          expect(sum.currency).to eq 'EUR'
        end
      end

      context "subtraction" do
        # TODO: write a cleaner spec
        it "returns the correct difference between amounts when subtracting money objects with the same currency" do
          difference = money_euro - money_euro2

          expect(difference.inspect).to eq Money.new(money_euro.amount - money_euro2.amount, 'EUR').inspect
          expect(difference.amount).to eq((550.55 - 101.01).round(2)) # keep float precision
          expect(difference.currency).to eq 'EUR'
        end

        it "returns the correct difference between amounts when subtracting money objects with different currencies" do
          difference = money_euro - money_usd
          expect(difference.inspect).to eq [
            Money.new((money_euro.amount - money_usd.conversion_amount('EUR')), 'EUR'),
            Money.new((money_euro.conversion_amount('USD') - money_usd.amount), 'USD')
          ].inspect
          expect(difference.map(&:amount)).to eq [(money_euro.amount - money_usd.conversion_amount('EUR')).round(2), (money_euro.conversion_amount('USD') - money_usd.amount).round(2)]
          expect(difference.map(&:currency)).to eq ['EUR', 'USD']
        end

        it "returns the correct difference when subtracting money objects from a numeric" do
          difference = money_euro - 10
          expect(difference.inspect).to eq Money.new(money_euro.amount - 10, 'EUR').inspect
          expect(difference.amount).to eq((550.55 - 10))
          expect(difference.currency).to eq 'EUR'
        end
      end

      context "multiplication" do
        # TODO: write a cleaner spec
        it "returns the correct product of amounts when multiplying money objects with the same currency" do
          product = money_euro * money_euro2

          expect(product.inspect).to eq Money.new(money_euro.amount * money_euro2.amount, 'EUR').inspect
          expect(product.amount).to eq((550.55 * 101.01).round(2)) # keep float precision
          expect(product.currency).to eq 'EUR'
        end

        it "returns the correct product of amounts when multiplying money objects with different currencies" do
          product = money_euro * money_usd
          expect(product.inspect).to eq [
            Money.new((money_euro.amount * money_usd.conversion_amount('EUR')), 'EUR'),
            Money.new((money_euro.conversion_amount('USD') * money_usd.amount), 'USD')
          ].inspect
          expect(product.map(&:amount)).to eq [(money_euro.amount * money_usd.conversion_amount('EUR')).round(2), (money_euro.conversion_amount('USD') * money_usd.amount).round(2)]
          expect(product.map(&:currency)).to eq ['EUR', 'USD']
        end

        it "returns the correct product when multiplying money objects with a numeric" do
          product = money_euro * 10
          expect(product.inspect).to eq Money.new(money_euro.amount * 10, 'EUR').inspect
          expect(product.amount).to eq((550.55 * 10))
          expect(product.currency).to eq 'EUR'
        end
      end

      context "division" do
        # TODO: write a cleaner spec
        it "returns the correct quotient of amounts when dividing money objects with the same currency" do
          quotient = money_euro / money_euro2

          expect(quotient.inspect).to eq Money.new(money_euro.amount / money_euro2.amount, 'EUR').inspect
          expect(quotient.amount).to eq((550.55 / 101.01).round(2)) # keep float precision
          expect(quotient.currency).to eq 'EUR'
        end

        it "returns the correct quotient of amounts when dividing money objects with different currencies" do
          quotient = money_euro / money_usd
          expect(quotient.inspect).to eq [
            Money.new((money_euro.amount / money_usd.conversion_amount('EUR')), 'EUR'),
            Money.new((money_euro.conversion_amount('USD') / money_usd.amount), 'USD')
          ].inspect
          expect(quotient.map(&:amount)).to eq [(money_euro.amount / money_usd.conversion_amount('EUR')).round(2), (money_euro.conversion_amount('USD') / money_usd.amount).round(2)]
          expect(quotient.map(&:currency)).to eq ['EUR', 'USD']
        end

        it "returns the correct quotient when divding money objects with a numeric" do
          quotient = money_euro / 10
          expect(quotient.inspect).to eq Money.new(money_euro.amount / 10, 'EUR').inspect
          expect(quotient.amount).to eq((550.55 / 10).round(2))
          expect(quotient.currency).to eq 'EUR'
        end
      end
    end

    describe "money comparison" do
      let(:money_euro)  { Money.new 550.55, 'EUR' }
      let(:money_euro2) { Money.new 101.01, 'EUR' }
      let(:money_usd)   { Money.new 101.01, 'USD' }
      let(:money_gbp)   { Money.new 101.01, 'GBP' }

      context "==" do
        it "compares money objects with the same currency" do
          expect(money_euro == money_euro).to be true
          expect(money_euro == money_euro2).to be false
          expect(money_euro == money_usd).to be false
        end

        it "compares money objects with different currencies" do
          expect(money_euro == money_usd).to be false
          expect(money_euro == money_gbp).to be false
        end
      end

      context "!=" do
        it "compares money objects with the same currency" do
          expect(money_euro != money_euro).to be false
          expect(money_euro != money_euro2).to be true
        end

        it "compares money objects with different currencies" do
          expect(money_euro != money_usd).to be true
          expect(money_euro != money_gbp).to be true
        end
      end

      context ">" do
        it "compares money objects with the same currency" do
          expect(money_euro > money_euro2).to be true
          expect(money_euro > money_euro).to be false
        end

        it "compares money objects with different currencies" do
          expect(money_euro > money_gbp).to be true
          expect(money_euro > money_usd).to be true
          expect(money_usd > money_euro).to be false
        end
      end

      context ">=" do
        it "compares money objects with the same currency" do
          expect(money_euro >= money_euro2).to be true
          expect(money_euro >= money_euro).to be true
        end

        it "compares money objects with different currencies" do
          expect(money_euro >= money_gbp).to be true
          expect(money_euro >= money_usd).to be true
          expect(money_usd >= money_euro).to be false
        end
      end

      context "<" do
        it "compares money objects with the same currency" do
          expect(money_euro < money_euro2).to be false
          expect(money_euro < money_euro).to be false
        end

        it "compares money objects with different currencies" do
          expect(money_euro < money_gbp).to be false
          expect(money_euro < money_usd).to be false
          expect(money_usd < money_euro).to be true
        end
      end

      context "<=" do
        it "compares money objects with the same currency" do
          expect(money_euro <= money_euro2).to be false
          expect(money_euro <= money_euro).to be true
        end

        it "compares money objects with different currencies" do
          expect(money_euro <= money_gbp).to be false
          expect(money_euro <= money_usd).to be false
          expect(money_usd <= money_euro).to be true
        end
      end

      context "<=>" do
        it "compares money objects with the same currency" do
          expect(money_euro <=> money_euro2).to eq(1)
          expect(money_euro <=> money_euro).to eq(0)
        end

        it "compares money objects with different currencies" do
          expect(money_gbp <=> money_euro).to eq(-1)
          expect(money_euro <=> money_usd).to eq(1)
          expect(money_usd <=> money_euro).to eq(-1)
        end
      end
    end
  end
end
