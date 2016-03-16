app.controller 'PaymentsListCtrl', ($scope, $rootScope, DataService, SimulationService) ->

  $scope.payments = []
  $scope.visiblePayments = []

  updateVisible = ->
    $scope.visiblePayments = []
    evaluator = -> true
    try
      if $scope.filterFunction and $scope.filterFunction.length > 0
        predicate = eval('(function(p){' + $scope.filterFunction + ';})')
        if _.isFunction predicate
          evaluator = predicate
    catch e
      console.warn(e)
    for p in $scope.payments
      show = true
      try
        show = evaluator(p)
      catch
      p.visible = show
      if show
        $scope.visiblePayments.push p

  convertPayment = (p, r) ->
    if p.account
      a = {
        currency: p.account.currency
        accountName: p.account.name
        color: p.account.color
      }
    else
      a = {}

    r.payment = p
    if r.amount != p.amount
      r.amountFormatted = numeral(p.amount).format('+0,0.00')
    r.amount = p.amount
    r.currency = a.currency
    r.accountName = a.accountName
    r.color = a.color
    r.id = p.id

    if p instanceof SimplePayment
      r.description = p.description
      r.type = 'Simple'
      r.date = p.date.toDate()
    if p instanceof BorrowPayment
      r.description = p.description
      r.type = 'Loan'
      r.date = p.date.toDate()
    if p instanceof PeriodicPayment
      r.description = p.description
      r.type = 'Periodic'
      r.date = p.startDate.toDate()
    if p instanceof TaxableIncomePayment
      r.description = p.params.description
      r.type = 'Income'
      r.date = p.params.paymentDate.toDate()

  update = ->
    payments = DataService.getAllPayments()

    _.merge {
      src: payments,
      dst: $scope.payments
      make: -> {}
      equals: (x, y) -> x.id == y.payment.id
      assign: (dst, src) -> convertPayment(src, dst)
      }
    $scope.payments = sortByDateAndId($scope.payments, (t) -> t.date.getTime())
    sortedByDate = _.clone($scope.payments)
    $scope.payments.reverse()

    wrappers = {}
    for w in $scope.payments
      wrappers[w.payment.id] = w

    fullState = SimulationService.getLastSimulation().currentAccountsState
    unmuted = DataService.getUnmutedPayments()
    for p in $scope.payments
      otherPayments = _.except(unmuted, (pp) -> pp.id == p.payment.id)
      r = SimulationService.runSimulationFor(otherPayments)
      state = r.currentAccountsState
      difference = 0
      for a, i in state.accounts
        b = state.balances[i]
        d = fullState.balances[i] - b
        difference += d
      if difference != p.absoluteEffectNum
        p.absoluteEffect = numeral(difference).format('+0,0.00')
        p.absoluteEffectNum = difference

    first = 1
    lastState = null
    for p in sortedByDate
      otherPayments = _.take(sortedByDate.map( (p) -> p.payment ), first)
      first++
      difference = 0
      if !p.payment.isMuted
        otherUnmuted = otherPayments.filter (p) -> !p.isMuted
        r = SimulationService.runSimulationFor(otherUnmuted)
        state = r.currentAccountsState
        for a, i in state.accounts
          b = state.balances[i]
          lastBalance = if lastState then lastState.balances[i] else 0
          d = b - lastBalance
          difference += d
        lastState = state
      else
        difference = 0
      if difference != p.chronoEffectNum
        p.chronoEffect = numeral(difference).format('+0,0.00')
        p.chronoEffectNum = difference


    updateVisible()
    return

  update()

  $scope.$watch 'filterFunction', ->
    updateVisible()

  $scope.enteredPayment = (payment) ->
    $rootScope.$broadcast('enterPayment', payment.payment)
  $scope.leftPayment = (payment) ->
    $rootScope.$broadcast('enterPayment', null)
  $scope.templateFor = (payment)->
    if payment instanceof BorrowPayment then return 'borrow-payment'
    if payment instanceof PeriodicPayment then return 'periodic-payment'
    if payment instanceof TaxableIncomePayment then return 'taxable-income-payment'
    return 'simple-payment'

  $scope.edit = (payment) ->
    payment.editPayment = payment.payment.clone()
    payment.showEdit = true

  $scope.cancelEdit = (payment) ->
    payment.showEdit = false
    payment.editPayment = null

  $scope.saveEdit = (payment) ->
    payment.editPayment.assignTo(payment.payment)
    payment.editPayment = null
    payment.showEdit = false
    DataService.updatePayment(payment.payment)
    DataService.notifyEdited()

  $scope.delete = (payment) ->
    DataService.deletePayment(payment.payment)

  $scope.mute = (payment) ->
    console.log 'muting...'
    payment.payment.isMuted = true
    DataService.notifyChanged()
    # update()

  $scope.unmute = (payment) ->
    payment.payment.isMuted = false
    DataService.notifyChanged()
    # update()

  $scope.unmuteAll = ->
    for p in $scope.payments
      p.payment.isMuted = false
    DataService.notifyChanged()
    # update()

  $scope.muteHidden = ->
    for p in $scope.payments
      if !p.visible
        p.payment.isMuted = true
    DataService.notifyChanged()
    # update()

  $scope.$on 'simulationRan', (__, c) ->
    update()
