app.controller 'NewPaymentCtrl', ($scope, $rootScope, DataService) ->
  paymentTypes = {
    simplePayment: SimplePayment
    borrowPayment: BorrowPayment
    periodicPayment: PeriodicPayment
    taxableIncomePayment: TaxableIncomePayment
  }
  $scope.anyVisible = false
  $scope.visibility = {}
  $scope.template = {}
  for k of paymentTypes
    ( (k) ->
      $scope.template[k] = new paymentTypes[k]
      $scope.visibility[k] = false
      $scope[_.camelCase('new_' + k)] = ->
        for kk of $scope.visibility
          if kk == k
            $scope.visibility[k] = !$scope.visibility[k]
          else
            $scope.visibility[kk] = false
        $scope.anyVisible = $scope.visibility[k]
    )(k)

  getVisible = ->
    for kk of $scope.visibility
      if $scope.visibility[kk]
        return kk
    return null

  $scope.addPayment = ->
    k = getVisible()
    payment = $scope.template[k]
    DataService.addPayment(payment)
    $scope.template[k] = new paymentTypes[k]
  return
