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
