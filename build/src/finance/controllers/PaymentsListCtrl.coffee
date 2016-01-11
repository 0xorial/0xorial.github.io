app.controller 'PaymentsListCtrl', ($scope, $rootScope, DataService) ->

  getPaymentInfo = (p) ->
    if p.account
      a = {
        currency: p.account.currency
        accountName: p.account.name
        color: p.account.color
      }
    else
      a = {}

    if p instanceof SimplePayment
      return {
        payment: p
        description: p.description
        type: 'Simple'
        date: p.date.toDate()
        amount: p.amount
        currency: a.currency
        accountName: a.accountName
        color: a.color
      }
    if p instanceof BorrowPayment
      return {
        payment: p
        description: p.description
        type: 'Loan'
        date: p.date.toDate()
        amount: p.amount
        currency: a.currency
        accountName: a.accountName
        color: a.color
      }
    if p instanceof PeriodicPayment
      return {
        payment: p
        description: p.description
        type: 'Periodic'
        date: p.startDate.toDate()
        amount: p.amount
        currency: a.currency
        accountName: a.accountName
        color: a.color
      }
    if p instanceof TaxableIncomePayment
      return {
        payment: p
        description: p.params.description
        type: 'Income(taxable)'
        date: p.params.earnedAt.toDate()
        amount: p.amount
        currency: a.currency
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
  $scope.templateFor = (payment)->
    x = ->
      if payment instanceof BorrowPayment then return 'borrowPayment'
      if payment instanceof PeriodicPayment then return 'periodicPayment'
      if payment instanceof TaxableIncomePayment then return 'taxableIncomePayment'
      return 'simplePayment'
    return _.kebabCase(x(payment))

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
    $rootScope.$broadcast 'dataChanged'

  $scope.delete = (payment) ->
    DataService.deletePayment(payment.payment)

  $scope.$on 'simulationRan', (__, c) ->
    update()

  $scope.newSimplePayment = ->
    $scope.payments.splice(0, 0, getPaymentInfo(new SimplePayment()))