app.service 'SavingService', (DataService, HistoryService, JsonSerializationService, GoogleDriveSaveService) ->

  serialize = () ->
    currentData = HistoryService.getData()
    return JSON.stringify(currentData, null, '  ')

  deserialize = (jsonString) ->
    parsed = JSON.parse(jsonString)
    HistoryService.setData(parsed)
    applyLatestStateInHistory()

  applyLatestStateInHistory = ->
    jsonState = HistoryService.peekState()
    state = JsonSerializationService.deserialize({payments: jsonState.payments, accounts: jsonState.accounts})
    DataService.setAccounts(state.accounts)
    DataService.setPayments(state.payments)
    DataService.notifyChanged()

  getIndex = ->
    accounts = DataService.getAccounts()
    payments = DataService.getAllPayments()
    accountsText = accounts.map((a) -> a.name).join(',')
    paymentsText = payments.map((p) -> p.description).join(',')
    return accountsText + ',' + paymentsText

  return {
    # getCurrentJson: -> currentData
    loadJson: (json) -> deserialize(json)
    getSerializedData: () -> return serialize()
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
        jsonState = JsonSerializationService.serialize({payments: demoPayments, accounts: demoAccounts})
        HistoryService.resetState()
        HistoryService.setInitialState(jsonState)
        cb(null, 'demo')
      else if _.startsWith(path, 'drive:')
        await GoogleDriveSaveService.loadFile(path.substring(6), defer(error, file, jsonStringData), progress)
        if error
          progress('Error loading file.')
          console.log error
          cb(error)
          return
        console.log file
        jsonData = JSON.parse(jsonStringData)
        HistoryService.setData(jsonData)
        cb(null, file.title)
      else
        throw new Error('unknown path')

      applyLatestStateInHistory()

    authorizeInDrive: -> (cb, progress) ->
      GoogleDriveSaveService.authorizeInDrive(cb, progress)
  }
