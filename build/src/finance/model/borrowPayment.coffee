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

  assignTo: (to) ->
    _.assign(to, @)

  toJson: (context) ->
    return {
      type: 'BorrowPayment'
      accountId: context.getObjectId(@account)
      date: @date.valueOf()
      returnDate: @returnDate.valueOf()
      amount: @amount
      description: @description
      interest: @interest
    }
  @fromJson: (json, context) ->
    return new exports.BorrowPayment(
      context.resolveObject(json.accountId),
      moment(json.date),
      moment(json.returnDate),
      json.amount,
      json.description,
      json.interest)
