app.controller 'NewPaymentCtrl', ($scope, $rootScope, DataService) ->
  paymentTypes = {
    simplePayment: SimplePayment
    borrowPayment: BorrowPayment
    periodicPayment: PeriodicPayment
    taxableIncomePayment: TaxableIncomePayment
  }
  $scope.visibility = {}
  $scope.template = {}
  for k of paymentTypes
    $scope.template[k] = new paymentTypes[k]
    $scope.visibility[k] = false
    $scope[_.camelCase('new_' + k)] = ->
      $scope.visibility[k] = !$scope.visibility[k]
