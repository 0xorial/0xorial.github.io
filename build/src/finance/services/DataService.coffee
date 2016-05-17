dataContainer = {
  accounts: []
  payments: []
  nextId: 1
  usedIds: {}
  filter: ''
}

thumbnail = null

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
      $rootScope.$broadcast 'dataEdited'

    addAccount: (account) ->
      dataContainer.accounts.push(account)
      ensureIds()
      $rootScope.$broadcast 'dataEdited'

    updateAccount: (account) ->
      existing = _.findIndex(dataContainer.accounts, (a) -> a.id == account.id)
      if existing == -1
        throw new Error('account not found')
      dataContainer.accounts[existing] = account

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
      $rootScope.$broadcast 'dataEdited'

    deletePayment: (payment) ->
      _.remove(dataContainer.payments, payment)
      ensureIds()
      $rootScope.$broadcast 'dataEdited'

    updatePayment: (payment) ->
      existing = _.findIndex(dataContainer.payments, (a) -> a.id == payment.id)
      if existing == -1
        throw new Error('payment not found')
      dataContainer.payments[existing] = payment

    setValues: (values) ->
      if !values
        throw new Error()
      dataContainer.values = values

    getValues: (values) ->
      return dataContainer.values

    setValue: (key, value) ->
      dataContainer.values[key] = value

    deleteValue: (key) ->
      delete dataContainer[key]

    getFilter: ->
      return dataContainer.filter

    setFilter: (f) ->
      dataContainer.filter = f

    notifyChanged: ->
      $rootScope.$broadcast 'dataChanged'

    notifyEdited: ->
      $rootScope.$broadcast 'dataChanged'
      $rootScope.$broadcast 'dataEdited'

    setThumbnail: (value) ->
      thumbnail = value

    getThumbnail: ->
      return thumbnail
    }
