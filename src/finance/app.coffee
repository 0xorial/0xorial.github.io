app = angular.module('StarterApp', [
  'md.data.table'
  'ngMaterial'
])

app.controller 'AppCtrl', ($rootScope, $scope, $timeout) ->


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

app.controller 'PaymentsListCtrl', ($scope, $rootScope, DataService) ->

  SimplePayment.augmentDate 'date'
  BorrowPayment.augmentDate 'date'
  BorrowPayment.augmentDate 'returnDate'
  TaxableIncomePayment.augmentDateDeep 'earnedAt',
    get: -> @params.earnedAt
    set: (v) -> @params.earnedAt = v

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
