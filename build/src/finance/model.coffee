
exports = window;

class exports.Account
  constructor: (@currency, @name, @color) ->

  toJson: (context) ->
    return {
      id: context.registerObject(@)
      currency: @currency
      name: @name
      color: @color
    }
  @fromJson: (json, context) ->
    r = new exports.Account(json.currency, json.name, json.color)
    context.registerObjectWithId(json.id, r)
    return r

class exports.AccountsState
  constructor: (@accounts, @balances) ->
    if !@balances
      @balances = @accounts.map -> 0

  execute: (account, amount) ->
    newBalances = []
    found = false
    for b, index in @balances
      a = @accounts[index]
      if not found and a == account
        found = true
        newBalances.push(b + amount)
      else
        newBalances.push(b)
    return new exports.AccountsState(@accounts, newBalances)

class exports.Transaction
  constructor: (@date, @amount, @account, @description, @payment, @id) ->

class exports.Payment
  # returns generator returning transactions ordered by payment time
  getTransactions: (context) ->
    throw new Error('abstract method')

  clone: ->
    c = new @constructor()
    @assignTo(c)
    return c

class exports.SimplePayment extends exports.Payment
  constructor: (@account, @date, @amount, @description) ->
    if !@date
      @date = moment()

  getTransactions: (context) ->
    context.transaction(@date, @amount, @account, @description, @)

  assignTo: (to) ->
    _.assign(to, @)

  toJson: (context) ->
    return {
      type: 'SimplePayment'
      date: @date.valueOf()
      amount: @amount
      accountId: context.getObjectId(@account)
      description: @description
    }
  @fromJson: (json, context) ->
    return new exports.SimplePayment(
      context.resolveObject(json.accountId),
      moment(json.date),
      json.amount,
      json.description)

class exports.PeriodicPayment extends exports.Payment
  constructor: (@account, @startDate, @endDate, @period, @amount, @description) ->
    if !@startDate
      @startDate = moment()
    if !@endDate
      @endDate = moment()

  getTransactions: (context) ->
    date = @startDate.clone()
    while date.isBefore(@endDate)
      context.transaction(date.clone(), @amount, @account, @description, @)
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

class exports.BorrowPayment extends exports.Payment
  constructor: (@account, @date, @returnDate, @amount, @description) ->
    if !@date
      @date = moment()
    if !@returnDate
      @returnDate = moment()

  getTransactions: (context) ->
    context.transaction(@date, @amount, @account, 'borrow ' + @description, @)
    returnAmount = @amount * (-1)
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
    }
  @fromJson: (json, context) ->
    return new exports.BorrowPayment(
      context.resolveObject(json.accountId),
      moment(json.date),
      moment(json.returnDate),
      json.amount,
      json.description)

class exports.TaxableIncomePayment extends exports.Payment
  constructor: (@account, @amount, @params) ->
    if !@params
      @params = {
        earnedAt: moment()
        paymentDate: moment()
      }
    # earnedAt
    # paymentDate
    # description

  getTransactions: (context) ->
    context.transaction(@params.paymentDate, @amount, @account, 'salary', @)
    taxDate = @params.earnedAt.clone().add(1, 'month')
    amount = @amount.amount
    vat = 0.21
    vatTaxAmount = @amount * (-vat)
    context.transaction(taxDate, vatTaxAmount, @account, 'vat', @)
    noVatAmount = @amount * (1 - vat)
    social = 0.22
    socialTaxAmount = noVatAmount * (-0.22)
    context.transaction(taxDate, socialTaxAmount, @account, 'social tax', @)
    incomeAmount = noVatAmount - socialTaxAmount
    incomeTaxAmount = incomeAmount * (-0.5)
    context.transaction(taxDate, incomeTaxAmount, @account, 'income tax', @)

  assignTo: (to) ->
    _.assign(to, @)
    to.params = {}
    _.assign(to.params, @params)


  toJson: (context) ->
    params = _.clone(@params)
    params.earnedAt = params.earnedAt.valueOf()
    params.paymentDate = params.paymentDate.valueOf()
    return {
      type: 'TaxableIncomePayment'
      accountId: context.getObjectId(@account)
      params: params
      amount: @amount
    }
  @fromJson: (json, context) ->
    params = _.clone(json.params)
    params.earnedAt = moment(params.earnedAt)
    params.paymentDate = moment(params.paymentDate)
    return new exports.TaxableIncomePayment(
      context.resolveObject(json.accountId),
      json.amount,
      params)

class exports.SimulationContext
  constructor: (@accounts) ->
    @nextTransactionId = 0
    @transactions = []
    @currentAccountsState = new exports.AccountsState(@accounts)

  transaction: (date, amount, account, description, payment) ->
    t = new exports.Transaction(date, amount, account, description, payment, @nextTransactionId++)
    @transactions.push t

  executeTransactions:  ->
    @transactions.sort (a,b) ->
      if a.date.isSame(b.date)
        if a.id == b.id
          return 0
        if a.id < b.id
          return -1
        return 1
      if a.date.isBefore(b.date)
        return -1
      return 1
    for t in @transactions
      newState = @currentAccountsState.execute(t.account, t.amount)
      t.accountState = newState
      @currentAccountsState = newState
