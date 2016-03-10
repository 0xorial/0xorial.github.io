
exports = window;

class exports.Account
  constructor: (@currency, @name, @color, @id) ->

  toJson: (context) ->
    if !@id
      throw new Error()
    return {
      id: context.registerObjectWithId(@, @id)
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

  getAccountBalance: (account) ->
    index = _.indexOf(@accounts, account)
    if index == -1
      throw new Error('account not found')
    return @balances[index]

class exports.Transaction
  constructor: (@date, @amount, @account, @description, @payment, @id) ->

class exports.Payment
  getTransactions: (context) ->
    throw new Error('abstract method')

  clone: ->
    c = new @constructor()
    @assignTo(c)
    return c

class exports.SimplePayment extends exports.Payment
  constructor: (@account, @date, @amount, @description, @isDeductible, @deductiblePercentage) ->
    if !@date
      @date = moment()
    @deductiblePercentage |= 0

  getTransactions: (context) ->
    context.transaction(@date, -@amount, @account, @description, @)

  assignTo: (to) ->
    _.assign(to, @)

  toJson: (context) ->
    return {
      type: 'SimplePayment'
      date: @date.valueOf()
      amount: @amount
      accountId: context.getObjectId(@account)
      description: @description
      isDeductible: @isDeductible
      deductiblePercentage: @deductiblePercentage
    }
  @fromJson: (json, context) ->
    return new exports.SimplePayment(
      context.resolveObject(json.accountId),
      moment(json.date),
      json.amount,
      json.description,
      json.isDeductible,
      json.deductiblePercentage)

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

class exports.BeTaxSystem
  calculate: (data, allPayments, context) ->
    isTaxableIncome = (p) -> p instanceof exports.TaxableIncomePayment
    payments = allPayments.filter(isTaxableIncome)
    if payments.length > 0
      account = _.first(payments).account
    deductiblePayments = allPayments.filter((p) -> p.isDeductible)
    deductibleExpensesByYear = _.groupBy(deductiblePayments, (p) -> p.date.year())
    byYear = _.groupBy(payments, (p) -> p.params.paymentDate.year())
    getDeductibaleVat = (p) -> (p.deductiblePercentage or 1)*p.amount*(p.vatPercentage or 0)
    getDeductibaleNonVat = (p) -> (p.deductiblePercentage or 1)*p.amount*(1 - (p.vatPercentage or 0))
    for year of byYear
      yearPayments = byYear[year]
      yearExpenses = deductibleExpensesByYear[year] or []

      #amount without VAT
      totalYearIncome = _.sumBy0(yearPayments, (p) -> p.amount * (1 - (p.params.vatPercentage or 0)))
      vatYearIncome = _.sumBy0(yearPayments, (p) -> p.amount * p.params.vatPercentage)

      deductibleVat = _.sumBy0(yearExpenses, getDeductibaleVat)
      deductibleNonVat = _.sumBy0(yearExpenses, getDeductibaleNonVat)

      # todo: does vat reduction increase personal income?...
      # currently assume it does
      totalYearIncome = totalYearIncome + deductibleVat

      totalYearIncome = totalYearIncome - deductibleNonVat

      vatToPay = vatYearIncome - deductibleVat
      vatToPay = 0 if vatToPay < 0

      # todo: when to pay vat?
      lastDayOfYear = moment({year: year}).add(1, 'year').subtract(1, 'days')
      context.transaction(lastDayOfYear, -vatToPay, account, 'vat payment', undefined)

      social = 0.22
      socialTaxToPay = totalYearIncome * social
      context.transaction(lastDayOfYear, -socialTaxToPay, account, 'social tax', undefined)

      allowance = 7090
      personalIncome = totalYearIncome - socialTaxToPay
      taxablePersonalIncome = personalIncome - allowance
      if taxablePersonalIncome < 0
        taxablePersonalIncome = 0
      personalTaxRate = 0
      if taxablePersonalIncome < 8680
        personalTaxRate = 0.25
      else if taxablePersonalIncome < 12360
        personalTaxRate = 0.3
      else if taxablePersonalIncome < 20600
        personalTaxRate = 0.4
      else if taxablePersonalIncome < 37750
        personalTaxRate = 0.45
      else
        personalTaxRate = 0.5

      personalTaxPayDate = moment({year: year + 1, month: 6})
      personalIncomeTaxToPay = taxablePersonalIncome * personalTaxRate
      t = context.transaction(lastDayOfYear, -personalIncomeTaxToPay, account, 'personal income tax', undefined)
      t.additionalInfo = 'Taxable personal income was: ' + taxablePersonalIncome + '. Tax rate applied was: ' + personalTaxRate


class exports.TaxableIncomePayment extends exports.Payment
  constructor: (@account, @amount, @params) ->
    if !@params
      @params = {
        vatPercentage: 0.21
        paymentDate: moment()
        deducibleExpenses: []
      }
    # vatPercentage
    # paymentDate
    # description

  getTransactions: (context) ->
    context.transaction(@params.paymentDate, @amount, @account, 'salary', @)

  assignTo: (to) ->
    _.assign(to, @)
    to.params = {}
    _.assign(to.params, @params)


  toJson: (context) ->
    params = _.clone(@params)
    params.paymentDate = params.paymentDate.valueOf()
    return {
      type: 'TaxableIncomePayment'
      accountId: context.getObjectId(@account)
      params: params
      amount: @amount
    }
  @fromJson: (json, context) ->
    params = _.clone(json.params)
    params.paymentDate = moment(params.paymentDate)
    return new exports.TaxableIncomePayment(
      context.resolveObject(json.accountId),
      json.amount,
      params)

exports.sortTransactions = (transactions) ->
  transactions.sort (a,b) ->
    if a.date.isSame(b.date)
      if a.id == b.id
        return 0
      if a.id < b.id
        return -1
      return 1
    if a.date.isBefore(b.date)
      return -1
    return 1

class exports.SimulationContext
  constructor: (@accounts) ->
    @nextTransactionId = 0
    @transactions = []
    @currentAccountsState = new exports.AccountsState(@accounts)

  transaction: (date, amount, account, description, payment) ->
    t = new exports.Transaction(date, amount, account, description, payment, @nextTransactionId++)
    @transactions.push t
    return t

  executeTransactions:  ->
    exports.sortTransactions @transactions

    for t in @transactions
      newState = @currentAccountsState.execute(t.account, t.amount)
      t.accountState = newState
      @currentAccountsState = newState
