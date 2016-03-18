app.service 'SavingService', ($rootScope, DataService, HistoryService, JsonSerializationService, GoogleDriveSaveService) ->

  undoPointer = -1
  possibleRedos = 0

  throttledUpdate = null

  updateInDrive = (documentPath, done, progress) ->
    if !_.startsWith(documentPath, 'drive:')
      throw new Erorr()
    id = documentPath.substring(6)
    data = serialize()
    GoogleDriveSaveService.updateFile(id, data, getIndex(), done, progress)

  $rootScope.$on 'dataEdited', ->
    if throttledUpdate
      throttledUpdate()

  serialize = () ->
    currentData = HistoryService.getData()
    return JSON.stringify(currentData, null, '  ')

  deserialize = (jsonString) ->
    parsed = JSON.parse(jsonString)
    HistoryService.setData(parsed)
    applyFromHistoryToDataService()

  applyFromHistoryToDataService = (pointer) ->
    jsonState = HistoryService.peekState(pointer)
    state = JsonSerializationService.deserialize(jsonState)
    DataService.setAccounts(state.accounts)
    DataService.setPayments(state.payments)
    DataService.setValues(state.values)
    DataService.notifyChanged()

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

  saveContinuously = (name, done, progress) ->
    driveDocumentName = name
    isDrive = true
    update = ->
      updateInDrive(name, done, progress)
    throttledUpdate = _.throttle(update, 2000)

  return {
    loadJson: (json) -> deserialize(json)
    getRawData: () -> return serialize()
    acceptChanges: ->
      applyFromDataToHistoryService()
      undoPointer = HistoryService.getStateHistoryCount() - 1
      return

    saveDrive: (documentPath, done, progress) ->
      updateInDrive(documentPath, done, progress)

    openDrive: (done, progress) ->
      GoogleDriveSaveService.showPicker(done, progress)
      saveContinuously(null, done, progress)

    saveNewDrive: (name, done, progress) ->
      data = serialize()
      GoogleDriveSaveService.newFile(name, data, getIndex(), done, progress)
      saveContinuously(name, done, progress)

    loadFile: (path, cb, progress) ->
      if path == 'demo'
        jsonState = JsonSerializationService.serialize({
          payments: demoPayments,
          accounts: demoAccounts,
          values: demoValues})
        HistoryService.resetState()
        HistoryService.acceptNewState(jsonState)
        undoPointer = HistoryService.getStateHistoryCount() - 1
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
        undoPointer = HistoryService.getStateHistoryCount() - 1
        saveContinuously('drive:' + file.id, cb, progress)
        cb(null, file.title)
      else
        throw new Error('unknown path')

      applyFromHistoryToDataService()

    authorizeInDrive: -> (cb, progress) ->
      GoogleDriveSaveService.authorizeInDrive(cb, progress)

    newFile: ->
      jsonState = JsonSerializationService.serialize({payments: [], accounts: [], values: {}})
      undoPointer = -1
      HistoryService.resetState()
      HistoryService.acceptNewState(jsonState)
      applyFromHistoryToDataService()

    canUndo: ->
      return undoPointer > 0

    undo: ->
      undoPointer--
      possibleRedos++
      # take state from history and set it to data service
      applyFromHistoryToDataService(undoPointer)
      # append state to the end of history
      applyFromDataToHistoryService('undo')

    canRedo: ->
      return possibleRedos > 0

    redo: ->
      undoPointer++
      possibleRedos--
      # take state from history and set it to data service
      applyFromHistoryToDataService(undoPointer)
      # append state to the end of history
      applyFromDataToHistoryService('redo')

  }
