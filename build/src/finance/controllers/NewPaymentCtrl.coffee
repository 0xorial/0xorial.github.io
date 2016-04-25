app.controller 'NewPaymentCtrl', ($scope, $rootScope, DataService, $mdDialog) ->

  $(document).on 'keydown', 'input', (e) ->
    keycode = e.keyCode;

    valid =
        (keycode > 47 && keycode < 58)   or # number keys
        keycode == 32 or keycode == 13   or # spacebar & return key(s) (if you want to allow carriage returns)
        (keycode > 64 && keycode < 91)   or # letter keys
        (keycode > 95 && keycode < 112)  or # numpad keys
        (keycode > 185 && keycode < 193) or # ;=,-./` (in order)
        (keycode > 218 && keycode < 223)
    if valid
      e.stopPropagation()
    return

  $(document).on 'keydown', (e) ->
    console.log e
    if e.keyCode == 78 # 'n'
      $scope.showMenu()
    if e.keyCode == 83 # 's'
      $scope.newSimplePayment(e)
    if e.keyCode == 66 # 'b'
      $scope.newBorrowPayment(e)
    if e.keyCode == 80 # 'p'
      $scope.newPeriodicPayment(e)
    if e.keyCode == 73 # 'i'
      $scope.newTaxableIncomePayment(e)

  $scope.showMenu = ($mdOpenMenu, ev) ->
    $mdOpenMenu(ev)

  getFirstAccount = ->
    DataService.getAccounts()[0]
  paymentTypes = {
    simplePayment: -> new SimplePayment(getFirstAccount(), moment(), 100, 'description', false, 1)
    borrowPayment: -> new BorrowPayment(getFirstAccount(), moment(), moment(), 100, 'description')
    periodicPayment: -> new PeriodicPayment(getFirstAccount(), moment(), moment(), {quantity: 1, units: 'months'}, 100, 'description')
    taxableIncomePayment: -> new TaxableIncomePayment(getFirstAccount(), 100)
  }
  $scope.anyVisible = false
  $scope.visibility = {}
  $scope.template = {}
  _scope = $scope
  for k of paymentTypes
    ( (k) ->
      $scope.template[k] = paymentTypes[k]()
      $scope.visibility[k] = false
      $scope[_.camelCase('new_' + k)] = (ev) ->
        for kk of $scope.visibility
          $scope.visibility[kk] = false
        $scope.visibility[k] = true

        $mdDialog.show({
          controller: ($scope, $mdDialog) ->
            $scope.template = _scope.template[k]
            $scope.templateName = _.kebabCase(k)
            $scope.ok = ->
              $mdDialog.hide()
              _scope.addPayment()
            $scope.cancel = ->
              $mdDialog.cancel()


          templateUrl: 'new-payment-dialog.html',
          parent: angular.element(document.body),
          targetEvent: ev,
          clickOutsideToClose:true
        })
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
