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
      t.amount = t.amount
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
