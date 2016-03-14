exports = window

class exports.BorrowPayment extends exports.Payment
  constructor: (@account, @date, @returnDate, @amount, @description, @interest) ->
    if !@interest
      @interest = 0
    if !@date
      @date = moment()
    if !@returnDate
      @returnDate = moment()

  getTransactions: (context) ->
    context.transaction(@date, @amount, @account, 'borrow ' + @description, @)
    diff = @returnDate.diff(@date)
    days = moment.duration(diff).asDays()
    fraction = days/365
    interest = fraction * @interest
    returnAmount = @amount * (-1) * (1 + interest)
    context.transaction(@returnDate, returnAmount, @account, 'return ' + @description, @)
