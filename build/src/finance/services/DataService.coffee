dataContainer = {
  accounts: []
  payments: []
  nextId: 1
  usedIds: {}
}

app.service 'DataService', ($rootScope) ->

  takeIdFor = (o) ->
    while (dataContainer.usedIds[dataContainer.nextId])
      dataContainer.nextId++
    o.id = dataContainer.nextId
    dataContainer.usedIds[o.id] = o
    dataContainer.nextId++
    return

  ensureId = (o) ->
    if !o.id
      takeIdFor(o)

  ensureIds = ->
    dataContainer.usedIds = {}
    for a in dataContainer.accounts
      if a.id
        dataContainer.usedIds[a.id] = a
    for p in dataContainer.payments
      if p.id
        dataContainer.usedIds[p.id] = p

    for a in dataContainer.accounts
      if !a.id
        takeIdFor(a)
    for p in dataContainer.payments
      if !p.id
        takeIdFor(p)

  return {
    getAccounts: ->
      return dataContainer.accounts

    setAccounts: (value) ->
      dataContainer.accounts = value
      ensureIds()

    deleteAccount: (account) ->
      _.remove(dataContainer.accounts, account)
      ensureIds()
      $rootScope.$broadcast 'dataChanged'

    addAccount: (account) ->
      dataContainer.accounts.push(account)
      ensureIds()
      $rootScope.$broadcast 'dataChanged'

    getAllPayments: ->
      return dataContainer.payments

    getUnmutedPayments: ->
      return dataContainer.payments.filter (p) -> !p.isMuted

    setPayments: (value) ->
      dataContainer.payments = value
      ensureIds()

    addPayment: (payment) ->
      dataContainer.payments.push payment
      ensureIds()
      $rootScope.$broadcast 'dataChanged'

    deletePayment: (payment) ->
      _.remove(dataContainer.payments, payment)
      ensureIds()
      $rootScope.$broadcast 'dataChanged'

    notifyChanged: ->
      $rootScope.$broadcast 'dataChanged'

    }
