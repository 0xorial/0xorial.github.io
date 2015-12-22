app = angular.module('StarterApp', [
  'ngMaterial'
])

app.controller 'AppCtrl', ($rootScope, $scope, $timeout) ->

class Currency

class CurrencyAmount
  constructor: (@currency, @amount) ->

  _getAmount: (currencyAmount) ->
    if currencyAmount.currency
      return currencyAmount.amount
    return currencyAmount

  multiply: (byy) ->
    return new CurrencyAmount(@currency, @amount * byy)

  add: (amount) ->
    return new CurrencyAmount(@currency, @amount + @_getAmount(amount))

  subtract: (amount) ->
    return new CurrencyAmount(@currency, @amount - @_getAmount(amount))

  isSame: (amount) ->
    return @currency == amount.currency and @amount == amount.amount

class Account
  constructor: (@currency, @balance, @name, @color) ->

  execute: (currencyAmount) ->
    if currencyAmount.currency != @currency
      throw new Error('wrong currency')
    @balance += currencyAmount.amount

  isSame: (other) ->
    return @ == other

class AccountSelector
  getAccounts: (@currencyAmount) ->
    throw new Error('abstract method')

class Transaction
  constructor: (@date, @currencyAmount, @account, @description, @payment) ->

  isSame: (other) ->
    return @date.isSame(other.date) \
      and @currencyAmount.isSame(other.currencyAmount) \
      and @account.isSame(other.account) \
      and @description == other.description \
      and @payment == other.payment

class Payment
  # returns generator returning transactions ordered by payment time
  getTransactions: ->
    throw new Error('abstract method')

  getTransactionsArray: ->
    return Array.from(@getTransactions())

class SimplePayment extends Payment
  constructor: (@accountSelector, @date, @currencyAmount, @description) ->
  getTransactions: ->
    account = @accountSelector.getAccounts(@currencyAmount)
    yield new Transaction(@date, @currencyAmount, account, @description)

class PeriodicPayment extends Payment
  constructor: (@accountSelector, @startDate, @endDate, @period, @currencyAmount, @description) ->
  getTransactions: ->
    date = @startDate
    while date < @endDate
      account = @accountSelector.getAccounts(@currencyAmount)
      yield new Transaction(date, @currencyAmount, account)
      date += @period

class BorrowPayment extends Payment
  constructor: (@accountSelector, @date, @returnDate, @currencyAmount, @description) ->
  getTransactions: ->
    account = @accountSelector.getAccounts(@currencyAmount)
    yield new Transaction(@date, @currencyAmount, account, 'borrow ' + @description)
    returnAmount = new CurrencyAmount(@currencyAmount.currency, -@currencyAmount.amount)
    account = @accountSelector.getAccounts(returnAmount)
    yield new Transaction(@returnDate, returnAmount, account, 'return ' + @description)

class TaxableIncomePayment extends Payment
  constructor: (@accountSelector, @currencyAmount, @params) ->
    # earnedAt
    # paymentDate

  getTransactions: ->
    account = @accountSelector.getAccounts(@currencyAmount)
    yield new Transaction(@params.paymentDate, @currencyAmount, account, 'salary')
    taxDate = @params.earnedAt.clone().add(1, 'month')
    amount = @currencyAmount.amount
    vat = 0.21
    vatTaxAmount = @currencyAmount.multiply(vat)
    yield new Transaction(taxDate, vatTaxAmount, account, 'vat')
    noVatAmount = @currencyAmount.multiply(1 - vat)
    social = 0.22
    socialTaxAmount = noVatAmount.multiply(0.22)
    yield new Transaction(taxDate, socialTaxAmount, account, 'social tax')
    incomeAmount = noVatAmount.subtract(socialTaxAmount)
    incomeTaxAmount = incomeAmount.multiply(0.5)
    yield new Transaction(taxDate, incomeTaxAmount, account, 'income tax')

class StaticAccountSelector extends AccountSelector
  constructor: (@account) ->
  getAccounts: (currencyAmount) ->
    return @account

class FirstSuitingSelector extends AccountSelector
  constructor: (@accounts) ->
  getAccounts: (currencyAmount) ->
    matching = @accounts.filter (a) -> a.currency == currencyAmount.currency
    if matching.length == 0
      return null
    return _.max(matching, 'balance')

account1 = new Account('EUR', 0, 'cash', 'green')
account2 = new Account('USD', 0, 'cash USD', 'yellow')
account3 = new Account('EUR', 0, 'bank corporate', 'orange')
account4 = new Account('EUR', 0, 'bank 2', 'blue')

eur = (a) -> new CurrencyAmount('EUR', a)
staticAccount = (a) -> new StaticAccountSelector(a)

allAccountsData = [account1, account2, account3, account4]

allAccounts = new FirstSuitingSelector(allAccountsData)

Types = {
  Simple: 'simple'
  Borrow: 'borrow'
  SimpleExpense: 'simpleExpense'
  BorrowReturn: 'borrowReturn'
  TaxableIncome: 'taxableIncome'
  PeriodicPayment: 'periodicPayment'
}

transactions = [
  {"id": 1, "type": Types.Simple, "date": "1/12/2015", "amount": 1000, "description": "initial money", "account": staticAccount(account1)},
  {"id": 2, "type": Types.Borrow, "date": "3/12/2015", "returnDate": "11/12/2015", "amount": 100, "description": "Tom", "account": staticAccount(account1)},
  {"id": 7, "type": Types.SimpleExpense, "date": "3/12/2015", "amount": 1050, "description": "bought bike", "account": allAccounts}
  {"id": 3, "type": Types.Borrow, "date": "4/12/2015", "returnDate": "11/12/2015",  "amount": 150, "description": "Wim", "account": staticAccount(account1)},
  {"id": 5, "type": Types.TaxableIncome, "date": "10/12/2015", "amount": 1000, "taxSystem": "be-self-employ", "account": staticAccount(account3)}
]


deserializePayment = (p) ->
  date = moment(p.date, "D-M-YYYY")
  accountSelector = p.account
  switch p.type
    when Types.Simple then return new SimplePayment(accountSelector, date, eur(p.amount), p.description)
    when Types.Borrow then return new BorrowPayment(accountSelector, date, moment(p.returnDate, "D-M-YYYY"), eur(p.amount), p.description)
    when Types.SimpleExpense then return new SimplePayment(accountSelector, date, eur(-p.amount), p.description)
    when Types.TaxableIncome
      params =
        earnedAt: date
        paymentDate: date
      return new TaxableIncomePayment(accountSelector, eur(p.amount), params)


app.controller 'TransactionsListCtrl', ($scope, SimulationService, DataService) ->
  $scope.allTransactions = SimulationService.getSimulated()
  $scope.simulateUntil = (transaction) ->
    $scope.allTransactions = SimulationService.getSimulated(transaction)
  $scope.simulateAll = () ->
    $scope.allTransactions = SimulationService.getSimulated()

  $scope.accounts = DataService.getAccounts()


app.controller 'AccountsController', ($scope, SimulationService, DataService) ->
  $scope.accounts = DataService.getAccounts()

app.service 'SimulationService', (DataService) ->
  runSimulation = (transaction) ->
    accounts = DataService.getAccounts()
    for a in accounts
      a.balance = 0

    payments = transactions.map (t) -> deserializePayment(t)
    tt = _.flatten(payments.map (t) -> t.getTransactionsArray())

    #todo: stabilize this sort
    tt.sort (a,b) ->
      return a.date.isAfter(b.date)

    transactionFound = false
    for t in tt
      if !transactionFound
        t.account.execute(t.currencyAmount)
      # t.moneyAfter = t.account.balance
      t.amount = t.currencyAmount.amount
      t.jsDate = t.date.toDate()
      t.color = t.account.color
      if transaction and transaction.isSame(t)
        transactionFound = true
    return tt

  return getSimulated: (transaction)->
    return runSimulation(transaction)

app.service 'DataService', ->
  return \
    getAccounts: ->
      return allAccountsData
