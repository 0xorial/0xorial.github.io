app.service 'SimulationService', ($rootScope, DataService, PaymentEvaluationContextService) ->

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
    evaluationContext = PaymentEvaluationContextService.getContext()
    for p in payments
      p.getTransactions(context, evaluationContext)

    t = new BeTaxSystem()
    t.calculate(null, payments, context, PaymentEvaluationContextService.getContext())

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
