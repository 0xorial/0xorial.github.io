app.service 'SavingService', (
  $rootScope,
  DataService,
  HistoryService,
  JsonSerializationService,
  PersistenceService,
  UndoRedoService) ->

  throttledUpdate = null

  $rootScope.$on 'dataEdited', ->
    PersistenceService.invalidateFile()

  serialize = () ->
    currentData = HistoryService.getData()
    return JSON.stringify(currentData, null, '  ')

  deserialize = (jsonString) ->
    parsed = JSON.parse(jsonString)
    HistoryService.setData(parsed)
    applyFromHistoryToDataService()

  applyFromHistoryToDataService = () ->
    jsonState = HistoryService.peekState()
    state = JsonSerializationService.deserialize(jsonState)
    DataService.setState(state)

  applyFromDataToHistoryService = (description) ->
    state = {
      payments: DataService.getAllPayments()
      accounts: DataService.getAccounts()
      values: DataService.getValues()
      }
    jsonState = JsonSerializationService.serialize(state)
    HistoryService.acceptNewState(jsonState, description)

  getIndex = ->
    accounts = DataService.getAccounts()
    payments = DataService.getAllPayments()
    accountsText = accounts.map((a) -> a.name).join(',')
    paymentsText = payments.map((p) -> p.description).join(',')
    return accountsText + ',' + paymentsText

  return {
    loadJson: (json) -> deserialize(json)
    getRawData: () -> return serialize()
    acceptChanges: ->
      applyFromDataToHistoryService()
      UndoRedoService.reset()
      return

    saveDrive: (documentPath, done, progress) ->
      PersistenceService.invalidateFile()

    openDrive: (done, progress) ->
      # GoogleDriveSaveService.showPicker(done, progress)
      # saveContinuously(null, done, progress)

    saveNewDrive: (name, done, progress) ->
      data = serialize()
      PersistenceService.saveNew({name: name, data: data, progress: progress, done: done})

    loadFile: (path, cb, progress) ->
      if path == 'demo'
        jsonState = JsonSerializationService.serialize({
          payments: demoPayments,
          accounts: demoAccounts,
          values: demoValues})
        HistoryService.resetState()
        HistoryService.acceptNewState(jsonState)
        cb(null, 'demo')
      else if _.startsWith(path, 'drive:')
        await PersistenceService.loadFile(path.substring(6), defer(error, file, jsonStringData), progress)
        if error
          progress('Error loading file.')
          console.log error
          cb(error)
          return
        console.log file
        jsonData = JSON.parse(jsonStringData)
        HistoryService.setData(jsonData)
        saveContinuously('drive:' + file.id, cb, progress)
        cb(null, file.title)
      else
        throw new Error('unknown path')
      UndoRedoService.reset()
      applyFromHistoryToDataService()

    authorizeInDrive: -> (cb, progress) ->
      GoogleDriveSaveService.authorizeInDrive(cb, progress)

    newFile: ->
      jsonState = JsonSerializationService.serialize({payments: [], accounts: [], values: {}})
      HistoryService.resetState()
      HistoryService.acceptNewState(jsonState)
      applyFromHistoryToDataService()
      UndoRedoService.reset()
  }
