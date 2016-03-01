app.service 'SavingService', (DataService, GoogleDriveSaveService) ->

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
    return JSON.stringify(root, null, '  ')

  deserialize = (jsonString) ->
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

  return {
    loadJson: (json) -> deserialize(json)
    saveJson: () -> return serialize()
    saveDrive: (documentPath, done, progress) ->
      if !_.startsWith(documentPath, 'drive:')
        throw new Erorr()
      id = documentPath.substring(6)
      data = serialize()
      GoogleDriveSaveService.updateFile(id, data, done, progress)

    saveNewDrive: (name, done, progress) ->
      data = serialize()
      GoogleDriveSaveService.newFile(name, data, done, progress)

    loadFile: (path, cb, progress) ->
      accounts = null
      payments = null
      if path == 'demo'
        accounts = demoAccounts
        payments = demoPayments
        DataService.setAccounts(accounts)
        DataService.setPayments(payments)
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

    documentChanged: (path) ->
    # updateDocument() ->
  }
