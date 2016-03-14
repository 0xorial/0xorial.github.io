exports = window

class exports.SimplePayment extends exports.Payment
  constructor: (@account, @date, @amount, @description, @isDeductible, @deductiblePercentage) ->
    if !@date
      @date = moment()
    @deductiblePercentage |= 0

  getTransactions: (context) ->
    context.transaction(@date, -@amount, @account, @description, @)

  assignTo: (to) ->
    _.assign(to, @)

  toJson: (context) ->
    return {
      type: 'SimplePayment'
      date: @date.valueOf()
      amount: @amount
      accountId: context.getObjectId(@account)
      description: @description
      isDeductible: @isDeductible
      deductiblePercentage: @deductiblePercentage
    }
  @fromJson: (json, context) ->
    return new exports.SimplePayment(
      context.resolveObject(json.accountId),
      moment(json.date),
      json.amount,
      json.description,
      json.isDeductible,
      json.deductiblePercentage)
