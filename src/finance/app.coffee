app = angular.module('StarterApp', [
  'md.data.table'
  'ngMaterial'
  'ngMdIcons'
  'mdColorPicker'
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

  $scope.$on 'simulationRan', (__, c) ->
    $scope.allTransactions = c.transactions

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
  $scope.autoSelect = true

  $scope.delete = (account) ->
    DataService.deleteAccount(account.account)

  $scope.add = ->
    name = $scope.newAccountName
    currency = $scope.newAccountCurrency
    DataService.addAccount(new Account(currency, name, 'white'))
    $scope.newAccountName = ''
    $scope.newAccountName = ''

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
    if !$scope.autoSelect
      return
    transaction = t
    update()


app.service 'SimulationService', ($rootScope, DataService) ->

  lastSimulation = null

  $rootScope.$on 'dataChanged', ->
    runSimulation()

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

    lastSimulation = context
    $rootScope.$broadcast 'simulationRan', lastSimulation
    return

  return {
    runSimulation: ->
      runSimulation()
      return lastSimulation
    getLastSimulation: ->
      return lastSimulation
  }

app.service 'DataService', ($rootScope)->
  return {
    getAccounts: ->
      return allAccountsData
    deleteAccount: (account) ->
      canDelete = true
      for p in payments
        if !p.accountSelector.canDeleteAcount(account)
          canDelete = false
      if !canDelete then return
      _.remove(allAccountsData, account)
      for p in payments
        p.accountSelector.notifyAccountDeleted(account)
      $rootScope.$broadcast 'dataChanged'

    addAccount: (account) ->
      allAccountsData.push(account)
      $rootScope.$broadcast 'dataChanged'


    getPayments: ->
      return payments
    }
