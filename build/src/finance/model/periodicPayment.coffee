exports = window

class exports.PeriodicPayment extends exports.Payment
  constructor: (@account, @startDate, @endDate, @period, @amount, @description) ->
    if !@startDate
      @startDate = moment()
    if !@endDate
      @endDate = moment()

  generateDates: ->
    result = []
    date = @startDate.clone()
    while date.isBefore(@endDate)
      result.push date.clone()
      date.add(@period.quantity, @period.units)
    return result


  getTransactions: (context, evaluator) ->
    currentState = {
      startDate: @startDate.valueOf()
      endDate: @endDate.valueOf()
      period: @period.valueOf()
    }
    dates = null
    p = if @lastState then @lastState.params else null
    c = currentState
    if @lastState and p.startDate == c.startDate and p.endDate == c.endDate and p.period == c.period
      dates = @lastState.dates
    else
      dates = @generateDates()
      @lastState = {
        params: currentState
        dates: dates
      }

    amount = @getAmount(evaluator)
    for date in dates
      context.transaction(date, -amount, @account, @description, @)
