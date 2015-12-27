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

  getPaymentInfo = (p) ->
    a = {
      accountName: p.account.name
      color: p.account.color
    }
    if p instanceof SimplePayment
      return {
        payment: p
        description: p.description
        type: 'Simple'
        date: p.date.toDate()
        amount: p.currencyAmount.amount
        currency: p.currencyAmount.currency
        accountName: a.accountName
        color: a.color
      }
    if p instanceof BorrowPayment
      return {
        payment: p
        description: p.description
        type: 'Loan'
        date: p.date.toDate()
        amount: p.currencyAmount.amount
        currency: p.currencyAmount.currency
        accountName: a.accountName
        color: a.color
      }
    if p instanceof PeriodicPayment
      return {
        payment: p
        description: p.description
        type: 'Periodic'
        date: p.date.toDate()
        amount: p.currencyAmount.amount
        currency: p.currencyAmount.currency
        accountName: a.accountName
        color: a.color
      }
    if p instanceof TaxableIncomePayment
      return {
        payment: p
        description: p.params.description
        type: 'Income(taxable)'
        date: p.params.earnedAt.toDate()
        amount: p.currencyAmount.amount
        currency: p.currencyAmount.currency
        accountName: a.accountName
        color: a.color
      }

  update = ->
    payments = DataService.getPayments()
    $scope.payments =  payments.map getPaymentInfo
  update()

  $scope.enteredPayment = (payment) ->
    $rootScope.$broadcast('enterPayment', payment.payment)
  $scope.leftPayment = (payment) ->
    $rootScope.$broadcast('enterPayment', null)
  $scope.templateFor = (payment) ->
    if payment instanceof BorrowPayment then return 'BorrowPayment.html'
    if payment instanceof PeriodicPayment then return 'PeriodicPayment.html'
    if payment instanceof TaxableIncomePayment then return 'TaxableIncomePayment.html'
    return 'SimplePayment.html'

  $scope.edit = (payment) ->
    payment.showEdit = true

  $scope.cancelEdit = (payment) ->
    payment.showEdit = false

  $scope.saveEdit = (payment) ->
    payment.update()
    payment.showEdit = false
    $rootScope.$broadcast 'dataChanged'

  $scope.delete = (payment) ->
    DataService.deletePayment(payment.payment)

  $scope.$on 'simulationRan', (__, c) ->
    update()

app.controller 'SimplePaymentEditCtrl', ($scope, DataService) ->
  $scope.payment = _.assign({}, $scope.p.payment)
  $scope.payment.date = $scope.payment.date.toDate()
  $scope.accounts = DataService.getAccounts()
  $scope.p.update = ->
    _.assign(@payment, $scope.payment)
    @payment.date = moment(@payment.date)

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

  stateMerge = (state) ->
    for b, index in state.balances
      $scope.accounts[index].balance = b
    return

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
    if $scope.accounts and $scope.accounts.length == state.accounts.length
      stateMerge(state)
    else
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
    for p in DataService.getPayments()
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
      _.remove(allAccountsData, account)
      $rootScope.$broadcast 'dataChanged'

    addAccount: (account) ->
      allAccountsData.push(account)
      $rootScope.$broadcast 'dataChanged'

    getPayments: ->
      return payments

    deletePayment: (payment) ->
      _.remove(payments, payment)
      $rootScope.$broadcast 'dataChanged'
    }
