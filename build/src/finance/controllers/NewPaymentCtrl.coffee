app.controller 'NewPaymentCtrl', ($scope, $rootScope, DataService) ->
  getFirstAccount = ->
    DataService.getAccounts()[0]
  paymentTypes = {
    simplePayment: -> new SimplePayment(getFirstAccount(), moment(), 100, 'description', false, 1 )
    borrowPayment: -> new BorrowPayment(getFirstAccount(), moment(), moment(), 100, 'description')
    periodicPayment: -> new PeriodicPayment(getFirstAccount(), moment(), moment(), {quantity: 1, units: 'months'}, 100, 'description')
    taxableIncomePayment: -> new TaxableIncomePayment(getFirstAccount(), 100)
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

  hideEditor = ->
    for kk of $scope.visibility
      $scope.visibility[kk] = false
    $scope.anyVisible = false


  $scope.addPayment = ->
    k = getVisible()
    payment = $scope.template[k]
    DataService.addPayment(payment)
    $scope.template[k] = new paymentTypes[k]
    hideEditor()
  return
