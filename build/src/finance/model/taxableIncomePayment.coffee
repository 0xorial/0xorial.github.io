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

  getTransactions: (context) ->
    context.transaction(@params.paymentDate, @amount, @account, 'salary', @)
