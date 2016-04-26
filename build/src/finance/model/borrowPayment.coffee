exports = window

class exports.BorrowPayment extends exports.Payment
  constructor: (@account, @date, @returnDate, @amount, @description, @interest, @tags) ->
    if !@interest
      @interest = 0
    if !@date
      @date = moment()
    if !@returnDate
      @returnDate = moment()

  getReturnMultiplier: ->
    diff = @returnDate.diff(@date)
    days = moment.duration(diff).asDays()
    fraction = days/365
    interest = fraction * @interest
    return -(1 + interest)

  getTransactions: (context, evaluationContext) ->
    amount = @getAmount(evaluationContext)
    currentState = {
      startDate: @date.valueOf()
      endDate: @returnDate.valueOf()
    }
    returnMultiplier = 0
    if @lastState and @lastState.params.startDate == currentState.startDate and @lastState.params.endDate == currentState.endDate
      returnMultiplier = @lastState.returnMultiplier
    else
      returnAmount = @getReturnMultiplier()
      @lastState = {
        params: currentState
        returnMultiplier: returnMultiplier
      }

    context.transaction(@date, amount, @account, 'borrow ' + @description, @)
    context.transaction(@returnDate, returnMultiplier * amount, @account, 'return ' + @description, @)
