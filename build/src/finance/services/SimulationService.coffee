app.service 'SimulationService', ($rootScope, DataService, FormulaEvaluationService) ->

  lastSimulation = null

  $rootScope.$on 'dataChanged', ->
    runSimulationGlobal()

  $rootScope.$on 'dataEdited', ->
    runSimulationGlobal()

  runSimulationGlobal = ->
    payments = DataService.getUnmutedPayments()
    lastSimulation = runSimulation(payments)
    $rootScope.$broadcast 'simulationRan', lastSimulation

  runSimulation = (payments) ->
    accounts = DataService.getAccounts()
    context = new SimulationContext(accounts)
    evaluator = FormulaEvaluationService.getEvaluator()
    for p in payments
      p.getTransactions(context, evaluator)

    t = new BeTaxSystem()
    t.calculate(null, payments, context, evaluator)

    context.executeTransactions()

    tt = context.transactions
    for t in tt
      # t.moneyAfter = t.account.balance
      t.amount = t.amount
      t.jsDate = t.date.toDate()
      t.color = t.account.color

    return context

  runSimulationGlobal()

  return {
    runSimulationFor: (payments) ->
      # allAccounts = payments.map((p) -> p.account)
      return runSimulation(payments)

    runSimulation: ->
      runSimulationGlobal()
      return lastSimulation

    getLastSimulation: ->
      return lastSimulation
  }
