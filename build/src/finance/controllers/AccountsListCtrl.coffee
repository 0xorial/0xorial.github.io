
app.controller 'AccountsListCtrl', ($scope, SimulationService, DataService) ->
  $scope.autoSelect = true

  $scope.delete = (account) ->
    DataService.deleteAccount(account.account)

  $scope.add = ->
    name = $scope.newAccountName
    currency = $scope.newAccountCurrency
    DataService.addAccount(new Account(currency, name, 'white'))
    $scope.newAccountName = ''
    $scope.newAccountCurrency = ''

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
    $scope.accounts = stateConvert state

  update()

  $scope.$on 'dataChanged', ->
    update()

  $scope.$on 'simulationRan', (__, c) ->
    context = c
    update()
