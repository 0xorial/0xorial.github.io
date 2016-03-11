app.controller 'PaymentsListCtrl', ($scope, $rootScope, DataService, SimulationService) ->

  $scope.payments = []
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
    r.amount = p.amount
    r.currency = a.currency
    r.accountName = a.accountName
    r.color = a.color

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
    $scope.payments = _.sortBy($scope.payments, 'date')

    fullState = SimulationService.getLastSimulation().currentAccountsState
    unmuted = DataService.getUnmutedPayments()
    for p in $scope.payments.filter( (pp) -> !pp.payment.isMuted)
      otherPayments = _.except(unmuted, (pp) -> pp.id == p.payment.id)
      r = SimulationService.runSimulationFor(otherPayments)
      state = r.currentAccountsState
      difference = 0
      for a, i in state.accounts
        b = state.balances[i]
        d = fullState.balances[i] - b
        difference += d
      p.effect = numeral(difference).format('+0.00')
    return

  update()

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
    DataService.notifyEdited()

  $scope.delete = (payment) ->
    DataService.deletePayment(payment.payment)

  $scope.mute = (payment) ->
    payment.payment.isMuted = true
    DataService.notifyChanged()
    update()

  $scope.unmute = (payment) ->
    payment.payment.isMuted = false
    DataService.notifyChanged()
    update()

  $scope.muteAll = ->
    for p in $scope.payments
      p.payment.isMuted = true
    DataService.notifyChanged()
    update()

  $scope.unmuteAll = ->
    for p in $scope.payments
      p.payment.isMuted = false
    DataService.notifyChanged()
    update()

  $scope.$on 'simulationRan', (__, c) ->
    update()
