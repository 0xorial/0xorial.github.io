exports = window

class exports.BorrowPayment extends exports.Payment
  constructor: (@account, @date, @returnDate, @amount, @description, @interest) ->
    if !@interest
      @interest = 0
    if !@date
      @date = moment()
    if !@returnDate
      @returnDate = moment()

  getReturnAmount: ->
    diff = @returnDate.diff(@date)
    days = moment.duration(diff).asDays()
    fraction = days/365
    interest = fraction * @interest
    returnAmount = @amount * (-1) * (1 + interest)
    return returnAmount

  getTransactions: (context) ->
    currentState = {
      startDate: @date.valueOf()
      endDate: @returnDate.valueOf()
    }
    returnAmount = 0
    if @lastState and @lastState.params.startDate == currentState.startDate and @lastState.params.endDate == currentState.endDate
      returnAmount = @lastState.returnAmount
    else
      returnAmount = @getReturnAmount()
      @lastState = {
        params: currentState
        returnAmount: returnAmount
      }

    context.transaction(@date, @amount, @account, 'borrow ' + @description, @)
    context.transaction(@returnDate, returnAmount, @account, 'return ' + @description, @)
