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
    loadJson: (json) ->
      # name = result.file.name
      jsonStringData = json
      jsonData = JSON.parse(jsonStringData)
      HistoryService.setData(jsonData)
      applyFromHistoryToDataService()
      return Promise.resolve()
    getRawData: () -> return serialize()
    acceptChanges: ->
      applyFromDataToHistoryService()
      UndoRedoService.reset()
      return

    save: () ->
      PersistenceService.invalidateFile()

    openDrive: (done, progress) ->
      # GoogleDriveSaveService.showPicker(done, progress)
      # saveContinuously(null, done, progress)

    saveNewDrive: (name, progress) ->
      data = serialize()
      return PersistenceService.saveNew({name: name, data: data, progress: progress})


    loadFile: (options) ->
      loadPromise = Promise.resolve()
      if options.path == 'demo'
        jsonState = JsonSerializationService.serialize({
          payments: demoPayments,
          accounts: demoAccounts,
          values: demoValues})
        HistoryService.resetState()
        HistoryService.acceptNewState(jsonState)
        loadPromise = Promise.resolve('demo')
      else if _.startsWith(options.path, 'drive:')
        loadPromise = PersistenceService.loadFile({id: options.path.substring(6), progress: options.progress})
        .then (result) ->
          name = result.file.name
          jsonStringData = result.data
          console.log result.file
          jsonData = JSON.parse(jsonStringData)
          HistoryService.setData(jsonData)
          Promise.resolve(result.file)
      else
        throw new Error('unknown path')
      loadPromise.then (file) ->
        UndoRedoService.reset()
        applyFromHistoryToDataService()
        return file

    authorizeInDrive: -> (cb, progress) ->
      GoogleDriveSaveService.authorizeInDrive(cb, progress)

    newFile: ->
      jsonState = JsonSerializationService.serialize({payments: [], accounts: [], values: {}})
      HistoryService.resetState()
      HistoryService.acceptNewState(jsonState)
      applyFromHistoryToDataService()
      UndoRedoService.reset()
  }
