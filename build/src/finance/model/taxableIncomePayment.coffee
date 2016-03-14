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

  assignTo: (to) ->
    _.assign(to, @)
    to.params = {}
    _.assign(to.params, @params)


  toJson: (context) ->
    params = _.clone(@params)
    params.paymentDate = params.paymentDate.valueOf()
    return {
      type: 'TaxableIncomePayment'
      accountId: context.getObjectId(@account)
      params: params
      amount: @amount
    }
  @fromJson: (json, context) ->
    params = _.clone(json.params)
    params.paymentDate = moment(params.paymentDate)
    return new exports.TaxableIncomePayment(
      context.resolveObject(json.accountId),
      json.amount,
      params)
