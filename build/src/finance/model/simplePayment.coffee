exports = window

class exports.SimplePayment extends exports.Payment
  constructor: (@account, @date, @amount, @description, @isDeductible, @deductiblePercentage) ->
    if !@date
      @date = moment()
    @deductiblePercentage |= 0

  getTransactions: (context, evaluator) ->
    context.transaction(@date, -@getAmount(evaluator), @account, @description, @)
