
app.service 'SavingService', (DataService, GoogleDriveSaveService) ->

  currentData = ''

  serialize = ->
    ctx = new SerializationContext()

    accounts = DataService.getAccounts()
    payments = DataService.getAllPayments()

    accounts = accounts.map (a) -> a.toJson(ctx)
    payments = payments.map (p) ->
      json = p.toJson(ctx)
      if !json.id
        json.id = p.id
      return json

    root = {
      accounts: accounts,
      payments: payments
    }
    currentData = JSON.stringify(root, null, '  ')
    return currentData

  deserialize = (jsonString) ->
    currentData = jsonString
    root = JSON.parse(jsonString)
    ctx = new SerializationContext()
    accounts = []
    for a in root.accounts
      account = Account.fromJson(a, ctx)
      account.id = a.id
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
        else
          throw new Error()
      payment.id = p.id
      payments.push payment

    DataService.setAccounts(accounts)
    DataService.setPayments(payments)
    DataService.notifyChanged()
    return

  getIndex = ->
    accounts = DataService.getAccounts()
    payments = DataService.getAllPayments()
    accountsText = accounts.map((a) -> a.name).join(',')
    paymentsText = payments.map((p) -> p.description).join(',')
    return accountsText + ',' + paymentsText

  return {
    getCurrentJson: -> currentData
    loadJson: (json) -> deserialize(json)
    saveJson: () -> return serialize()
    saveDrive: (documentPath, done, progress) ->
      if !_.startsWith(documentPath, 'drive:')
        throw new Erorr()
      id = documentPath.substring(6)
      data = serialize()
      GoogleDriveSaveService.updateFile(id, data, getIndex(), done, progress)

    openDrive: (done, progress) ->
      GoogleDriveSaveService.showPicker(done, progress)

    saveNewDrive: (name, done, progress) ->
      data = serialize()
      GoogleDriveSaveService.newFile(name, data, getIndex(), done, progress)

    loadFile: (path, cb, progress) ->
      if path == 'demo'
        DataService.setAccounts(demoAccounts)
        DataService.setPayments(demoPayments)
        DataService.notifyChanged()
        cb(null, 'demo')
      else if _.startsWith(path, 'drive:')
        await GoogleDriveSaveService.loadFile(path.substring(6), defer(error, file, data), progress)
        if !error
          deserialize(data)
          console.log file
          cb(error, file.title)
        else
          progress('Error loading file.')
          cb(error)
      else
        throw new Error('unknown path')

    authorizeInDrive: -> (cb, progress) ->
      GoogleDriveSaveService.authorizeInDrive(cb, progress)

    documentChanged: (path) ->
    # updateDocument() ->
  }
