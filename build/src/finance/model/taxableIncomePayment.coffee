exports = window

class exports.TaxableIncomePayment extends exports.Payment
  constructor: (@account, @amount, @params) ->
    if !@params
      @params = {
        vatPercentage: 0.21
        paymentDate: moment()
        deducibleExpenses: []
      }
    # vatPercentage
    # paymentDate
    # description

  getTransactions: (context, evaluator) ->
    context.transaction(@params.paymentDate, @getAmount(evaluator), @account, 'salary', @)
