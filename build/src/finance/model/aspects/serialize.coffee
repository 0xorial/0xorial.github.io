exports = window

payments = window

payments.Payment.prototype.toJson = () ->
  json = {
    tags: @tags
  }
  @toJsonImpl(json)
  return json

payments.Payment.prototype.fromJson = (json, ctx) ->
  @tags = json.tags
  @fromJsonImpl(json, ctx)

payments.SimplePayment.prototype.toJsonImpl = (json) ->
  json.date = @date.valueOf()
  json.amount = @amount
  json.accountId = @account.id
  json.description = @description
  json.isDeductible = @isDeductible
  json.deductiblePercentage = @deductiblePercentage

payments.SimplePayment.prototype.fromJsonImpl = (json, context) ->
  @account = context.resolveObject(json.accountId)
  @date = moment(json.date)
  @amount = json.amount
  @description = json.description
  @isDeductible = json.isDeductible
  @deductiblePercentage = json.deductiblePercentage

payments.BorrowPayment.prototype.toJsonImpl = (json) ->
  json.accountId = @account.id
  json.date = @date.valueOf()
  json.returnDate = @returnDate.valueOf()
  json.amount = @amount
  json.description = @description
  json.interest = @interest
  json.tags = @tags

payments.BorrowPayment.prototype.fromJsonImpl = (json, context) ->
  @account = context.resolveObject(json.accountId)
  @date = moment(json.date)
  @returnDate = moment(json.returnDate)
  @amount = json.amount
  @description = json.description
  @interest = json.interest

payments.PeriodicPayment.prototype.toJsonImpl = (json) ->
    json.accountId = @account.id
    json.startDate = @startDate.valueOf()
    json.endDate  = @endDate.valueOf()
    json.period = @period
    json.amount = @amount
    json.description  = @description

payments.PeriodicPayment.prototype.fromJsonImpl = (json, context) ->
  @account = context.resolveObject(json.accountId)
  @startDate = moment(json.startDate)
  @endDate = moment(json.endDate)
  @period = json.period
  @amount = json.amount
  @description = json.description

payments.TaxableIncomePayment.prototype.toJsonImpl = (json) ->
  params = _.clone(@params)
  params.paymentDate = params.paymentDate.valueOf()
  json.accountId = @account.id
  json.params = params
  json.amount = @amount

payments.TaxableIncomePayment.prototype.fromJson = (json, context) ->
  params = _.clone(json.params)
  params.paymentDate = moment(params.paymentDate)
  @account = context.resolveObject(json.accountId)
  @amount = json.amount
  @params = params
