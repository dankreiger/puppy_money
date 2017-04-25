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
  end
end
