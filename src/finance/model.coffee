
exports = window;

class exports.CurrencyAmount
  constructor: (@currency, @amount) ->

  _getAmount: (currencyAmount) ->
    if currencyAmount.currency
      return currencyAmount.amount
    return currencyAmount

  multiply: (byy) ->
    return new exports.CurrencyAmount(@currency, @amount * byy)

  add: (amount) ->
    return new exports.CurrencyAmount(@currency, @amount + @_getAmount(amount))

  subtract: (amount) ->
    return new exports.CurrencyAmount(@currency, @amount - @_getAmount(amount))

  isSame: (amount) ->
    return @currency == amount.currency and @amount == amount.amount

class exports.Account
  constructor: (@currency, @name, @color) ->

  isSame: (other) ->
    return @ == other

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


class exports.AccountSelector
  getAccounts: (context, currencyAmount) ->
    throw new Error('abstract method')

class exports.Transaction
  constructor: (@date, @currencyAmount, @account, @description, @payment, @id) ->

  isSame: (other) ->
    return @date.isSame(other.date) \
      and @currencyAmount.isSame(other.currencyAmount) \
      and @account.isSame(other.account) \
      and @description == other.description \
      and @payment == other.payment

class exports.Payment
  # returns generator returning transactions ordered by payment time
  getTransactions: (context) ->
    throw new Error('abstract method')

class exports.SimplePayment extends exports.Payment
  constructor: (@accountSelector, @date, @currencyAmount, @description) ->
  getTransactions: (context) ->
    account = @accountSelector.getAccounts(context, @currencyAmount)
    context.transaction(@date, @currencyAmount, account, @description, @)

class exports.PeriodicPayment extends exports.Payment
  constructor: (@accountSelector, @startDate, @endDate, @period, @currencyAmount, @description) ->
  getTransactions: (context) ->
    date = @startDate
    while date < @endDate
      account = @accountSelector.getAccounts(context, @currencyAmount)
      context.transaction(date, @currencyAmount, account, @)
      date += @period

class exports.BorrowPayment extends exports.Payment
  constructor: (@accountSelector, @date, @returnDate, @currencyAmount, @description) ->
  getTransactions: (context) ->
    account = @accountSelector.getAccounts(context, @currencyAmount)
    context.transaction(@date, @currencyAmount, account, 'borrow ' + @description, @)
    returnAmount = @currencyAmount.multiply(-1)
    account = @accountSelector.getAccounts(context, returnAmount)
    context.transaction(@returnDate, returnAmount, account, 'return ' + @description, @)

class exports.TaxableIncomePayment extends exports.Payment
  constructor: (@accountSelector, @currencyAmount, @params) ->
    # earnedAt
    # paymentDate

  getTransactions: (context) ->
    account = @accountSelector.getAccounts(context, @currencyAmount)
    context.transaction(@params.paymentDate, @currencyAmount, account, 'salary', @)
    taxDate = @params.earnedAt.clone().add(1, 'month')
    amount = @currencyAmount.amount
    vat = 0.21
    vatTaxAmount = @currencyAmount.multiply(-vat)
    context.transaction(taxDate, vatTaxAmount, account, 'vat', @)
    noVatAmount = @currencyAmount.multiply(1 - vat)
    social = 0.22
    socialTaxAmount = noVatAmount.multiply(-0.22)
    context.transaction(taxDate, socialTaxAmount, account, 'social tax', @)
    incomeAmount = noVatAmount.subtract(socialTaxAmount)
    incomeTaxAmount = incomeAmount.multiply(-0.5)
    context.transaction(taxDate, incomeTaxAmount, account, 'income tax', @)

class exports.StaticAccountSelector extends exports.AccountSelector
  constructor: (@account) ->
  getAccounts: (context, currencyAmount) ->
    return @account

class exports.FirstSuitingSelector extends exports.AccountSelector
  constructor: (@accounts) ->
  getAccounts: (context, currencyAmount) ->
    matching = @accounts.filter (a) -> a.currency == currencyAmount.currency
    if matching.length == 0
      return null
    return matching[0]

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
        return a.id > b.id
      return a.date.isAfter(b.date)
    for t in @transactions
      newState = @currentAccountsState.execute(t.account, t.currencyAmount.amount)
      t.accountState = newState
      @currentAccountsState = newState
