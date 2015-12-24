app = angular.module('StarterApp', [
  'md.data.table'
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
  constructor: (@currency, @name, @color) ->

  isSame: (other) ->
    return @ == other

class AccountsState
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
    return new AccountsState(@accounts, newBalances)


class AccountSelector
  getAccounts: (context, currencyAmount) ->
    throw new Error('abstract method')

class Transaction
  constructor: (@date, @currencyAmount, @account, @description, @payment, @id) ->

  isSame: (other) ->
    return @date.isSame(other.date) \
      and @currencyAmount.isSame(other.currencyAmount) \
      and @account.isSame(other.account) \
      and @description == other.description \
      and @payment == other.payment

class Payment
  # returns generator returning transactions ordered by payment time
  getTransactions: (context) ->
    throw new Error('abstract method')

class SimplePayment extends Payment
  constructor: (@accountSelector, @date, @currencyAmount, @description) ->
  getTransactions: (context) ->
    account = @accountSelector.getAccounts(context, @currencyAmount)
    context.transaction(@date, @currencyAmount, account, @description, @)

class PeriodicPayment extends Payment
  constructor: (@accountSelector, @startDate, @endDate, @period, @currencyAmount, @description) ->
  getTransactions: (context) ->
    date = @startDate
    while date < @endDate
      account = @accountSelector.getAccounts(context, @currencyAmount)
      context.transaction(date, @currencyAmount, account, @)
      date += @period

class BorrowPayment extends Payment
  constructor: (@accountSelector, @date, @returnDate, @currencyAmount, @description) ->
  getTransactions: (context) ->
    account = @accountSelector.getAccounts(context, @currencyAmount)
    context.transaction(@date, @currencyAmount, account, 'borrow ' + @description, @)
    returnAmount = @currencyAmount.multiply(-1)
    account = @accountSelector.getAccounts(context, returnAmount)
    context.transaction(@returnDate, returnAmount, account, 'return ' + @description, @)

class TaxableIncomePayment extends Payment
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

class StaticAccountSelector extends AccountSelector
  constructor: (@account) ->
  getAccounts: (context, currencyAmount) ->
    return @account

class FirstSuitingSelector extends AccountSelector
  constructor: (@accounts) ->
  getAccounts: (context, currencyAmount) ->
    matching = @accounts.filter (a) -> a.currency == currencyAmount.currency
    if matching.length == 0
      return null
    return matching[0]

class SimulationContext
  constructor: (@accounts) ->
    @nextTransactionId = 0
    @transactions = []
    @currentAccountsState = new AccountsState(@accounts)

  transaction: (date, amount, account, description, payment) ->
    t = new Transaction(date, amount, account, description, payment, @nextTransactionId++)
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


account1 = new Account('EUR', 'cash', 'green')
account2 = new Account('USD', 'cash USD', 'yellow')
account3 = new Account('EUR', 'bank corporate', 'orange')
account4 = new Account('EUR', 'bank 2', 'blue')

eur = (a) -> new CurrencyAmount('EUR', a)
staticAccount = (a) -> new StaticAccountSelector(a)

allAccountsData = [account1, account2, account3, account4]

allAccounts = new FirstSuitingSelector(allAccountsData)

Types = {
  Simple: 'simple'
  Borrow: 'borrow'
  SimpleExpense: 'simpleExpense'
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

payments = transactions.map (t) -> deserializePayment(t)

app.controller 'TransactionsListCtrl', ($scope, $rootScope, SimulationService, DataService) ->

  context = SimulationService.runSimulation()
  $scope.allTransactions = context.transactions

  $scope.simulateUntil = (transaction) ->
    $rootScope.$broadcast 'enterTransaction', transaction
  $scope.simulateAll = () ->
    $rootScope.$broadcast 'enterTransaction', null

  $scope.$on 'enterPayment', (__, payment) ->
    for t in $scope.allTransactions
      t.higlight = t.payment == payment

  $scope.selected = [];

  $scope.query = {
    filter: '',
    order: 'name',
    limit: 5,
    page: 1
  };

  success = (desserts) ->
    $scope.desserts = desserts

  $scope.search = (predicate) ->
    $scope.filter = predicate;
    $scope.deferred = $nutrition.desserts.get($scope.query, success).$promise;


  $scope.onOrderChange = (order) ->
    return $nutrition.desserts.get($scope.query, success).$promise;

  $scope.onPaginationChange = (page, limit) ->
    return $nutrition.desserts.get($scope.query, success).$promise;


app.controller 'PaymentsListCtrl', ($scope, $rootScope, DataService) ->
  $scope.payments = DataService.getPayments()
  $scope.enteredPayment = (payment) ->
    $rootScope.$broadcast('enterPayment', payment)
  $scope.leftPayment = (payment) ->
    $rootScope.$broadcast('enterPayment', null)
  $scope.templateFor = (payment) ->
    if payment instanceof BorrowPayment then return 'BorrowPayment.html'
    if payment instanceof PeriodicPayment then return 'PeriodicPayment.html'
    if payment instanceof TaxableIncomePayment then return 'TaxableIncomePayment.html'
    return 'SimplePayment.html'

app.controller 'AccountsListCtrl', ($scope, SimulationService, DataService) ->

  stateConvert = (state) ->
    acc = _.zip(state.accounts, state.balances)
      .map (a) -> { account: a[0], balance: a[1]}
    return acc

  context = SimulationService.getLastSimulation()
  transaction = null

  update = ->
    if not context
      return
    state = context.currentAccountsState
    date = _.last(context.transactions).date
    if transaction
      state = transaction.accountState
      date = transaction.date
    $scope.accounts = stateConvert state
    $scope.date = date.toDate()

  update()

  $scope.$on 'simulationRan', (__, c) ->
    context = c
    update()

  $scope.$on 'enterTransaction', (__, t) ->
    transaction = t
    update()


app.service 'SimulationService', ($rootScope, DataService) ->
  runSimulation = ->
    context = new SimulationContext(DataService.getAccounts())
    for p in payments
      p.getTransactions(context)

    context.executeTransactions()

    tt = context.transactions
    for t in tt
      # t.moneyAfter = t.account.balance
      t.amount = t.currencyAmount.amount
      t.jsDate = t.date.toDate()
      t.color = t.account.color
    return context

  lastSimulation = null
  return {
    runSimulation: ->
      lastSimulation = runSimulation()
      $rootScope.$broadcast 'simulationRan', lastSimulation
      return lastSimulation
    getLastSimulation: ->
      return lastSimulation
  }

app.service 'DataService', ->
  return {
    getAccounts: ->
      return allAccountsData
    getPayments: ->
      return payments
    }

app.service 'SelectionService', ->
  # selectedPayment
