exports = window

class exports.PeriodicPayment extends exports.Payment
  constructor: (@account, @startDate, @endDate, @period, @amount, @description) ->
    if !@startDate
      @startDate = moment()
    if !@endDate
      @endDate = moment()

  getTransactions: (context) ->
    date = @startDate.clone()
    while date.isBefore(@endDate)
      context.transaction(date.clone(), -@amount, @account, @description, @)
      date.add(@period.quantity, @period.units)

  assignTo: (to) ->
    _.assign(to, @)

  toJson: (context) ->
    return {
      type: 'PeriodicPayment'
      accountId: context.getObjectId(@account)
      startDate: @startDate.valueOf()
      endDate : @endDate.valueOf()
      period: @period
      amount: @amount
      description : @description
    }
  @fromJson: (json, context) ->
    return new exports.PeriodicPayment(
      context.resolveObject(json.accountId),
      moment(json.startDate),
      moment(json.endDate),
      json.period,
      json.amount,
      json.description)
