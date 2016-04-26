exports = window

payments = window

payments.Payment.prototype.toJson = ->
  throw new Error('abstract method')

payments.Payment.fromJson = ->
  throw new Error('abstract method')

payments.SimplePayment.prototype.toJson = (context) ->
  return {
    type: 'SimplePayment'
    date: @date.valueOf()
    amount: @amount
    accountId: context.getObjectId(@account)
    description: @description
    isDeductible: @isDeductible
    deductiblePercentage: @deductiblePercentage
    tags: @tags
  }

payments.SimplePayment.fromJson = (json, context) ->
  return new exports.SimplePayment(
    context.resolveObject(json.accountId),
    moment(json.date),
    json.amount,
    json.description,
    json.isDeductible,
    json.deductiblePercentage,
    json.tags)

payments.BorrowPayment.prototype.toJson = (context) ->
  return {
    type: 'BorrowPayment'
    accountId: context.getObjectId(@account)
    date: @date.valueOf()
    returnDate: @returnDate.valueOf()
    amount: @amount
    description: @description
    interest: @interest
    tags: @tags
  }
payments.BorrowPayment.fromJson = (json, context) ->
  return new exports.BorrowPayment(
    context.resolveObject(json.accountId),
    moment(json.date),
    moment(json.returnDate),
    json.amount,
    json.description,
    json.interest)

payments.PeriodicPayment.prototype.toJson = (context) ->
  return {
    type: 'PeriodicPayment'
    accountId: context.getObjectId(@account)
    startDate: @startDate.valueOf()
    endDate : @endDate.valueOf()
    period: @period
    amount: @amount
    description : @description
    tags: @tags
  }

payments.PeriodicPayment.fromJson = (json, context) ->
  return new exports.PeriodicPayment(
    context.resolveObject(json.accountId),
    moment(json.startDate),
    moment(json.endDate),
    json.period,
    json.amount,
    json.description,
    json.tags)

payments.TaxableIncomePayment.prototype.toJson = (context) ->
  params = _.clone(@params)
  params.paymentDate = params.paymentDate.valueOf()
  return {
    type: 'TaxableIncomePayment'
    accountId: context.getObjectId(@account)
    params: params
    amount: @amount
    tags: @tags
  }
payments.TaxableIncomePayment.fromJson = (json, context) ->
  params = _.clone(json.params)
  params.paymentDate = moment(params.paymentDate)
  return new exports.TaxableIncomePayment(
    context.resolveObject(json.accountId),
    json.amount,
    json.tags,
    params)
