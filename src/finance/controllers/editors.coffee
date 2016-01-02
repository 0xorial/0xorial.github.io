
app.controller 'SimplePaymentEditCtrl', ($scope, DataService) ->
  $scope.payment = _.assign({}, $scope.p.payment)
  $scope.payment.date = $scope.payment.date.toDate()
  $scope.accounts = DataService.getAccounts()
  $scope.p.update = ->
    _.assign(@payment, $scope.payment)
    @payment.date = moment(@payment.date)

app.controller 'BorrowPaymentEditCtrl', ($scope, DataService) ->
  $scope.payment = _.assign({}, $scope.p.payment)
  $scope.payment.date = $scope.payment.date.toDate()
  $scope.payment.returnDate = $scope.payment.returnDate.toDate()
  $scope.accounts = DataService.getAccounts()
  $scope.p.update = ->
    _.assign(@payment, $scope.payment)
    @payment.date = moment(@payment.date)
    @payment.returnDate = moment(@payment.returnDate)

app.controller 'PeriodicPaymentEditCtrl', ($scope, DataService) ->
  $scope.payment = _.assign({}, $scope.p.payment)
  $scope.payment.startDate = $scope.payment.startDate.toDate()
  $scope.payment.endDate = $scope.payment.endDate.toDate()
  $scope.accounts = DataService.getAccounts()
  $scope.p.update = ->
    _.assign(@payment, $scope.payment)
    @payment.startDate = moment(@payment.startDate)
    @payment.endDate = moment(@payment.endDate)

app.controller 'TaxableIncomePaymentEditCtrl', ($scope, DataService) ->
  $scope.payment = _.assign({}, $scope.p.payment)
  $scope.payment.earnedAt = $scope.payment.params.earnedAt.toDate()
  $scope.payment.paymentDate = $scope.payment.params.paymentDate.toDate()
  $scope.accounts = DataService.getAccounts()
  $scope.p.update = ->
    _.assign(@payment, $scope.payment)
    @payment.params.earnedAt = moment(@payment.earnedAt)
    @payment.params.paymentDate = moment(@payment.paymentDate)
