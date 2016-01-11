app.controller 'SerializationCtrl', ($scope, $rootScope, DataService) ->

  serialize = ->
    ctx = new SerializationContext()

    accounts = DataService.getAccounts()
    payments = DataService.getPayments()

    accounts = accounts.map (a) -> a.toJson(ctx)
    payments = payments.map (p) -> p.toJson(ctx)

    root = {
      accounts: accounts,
      payments: payments
    }
    $scope.serializedData = JSON.stringify(root, null, '  ')

  deserialize = ->
    root = JSON.parse($scope.serializedData)
    ctx = new SerializationContext()
    accounts = []
    for a in root.accounts
      account = Account.fromJson(a, ctx)
      accounts.push account

    payments = []
    for p in root.payments
      payment = null
      switch p.type
        when 'SimplePayment'
          payment = SimplePayment.fromJson(p, ctx)
        when 'BorrowPayment'
          payment = BorrowPayment.fromJson(p, ctx)
        when 'PeriodicPayment'
          payment = PeriodicPayment.fromJson(p, ctx)
        when 'TaxableIncomePayment'
          payment = TaxableIncomePayment.fromJson(p, ctx)

      if payment == null
        throw new Error()

      payments.push payment

    DataService.setAccounts(accounts)
    DataService.setPayments(payments)
    $rootScope.$broadcast 'dataChanged'

  $scope.loadData = ->
    deserialize()
  $scope.saveData = ->
    serialize()
