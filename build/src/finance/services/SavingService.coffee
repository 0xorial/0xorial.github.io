app.service 'SavingService', (
  DocumentDataService,
  PersistenceService,
  UndoRedoService) ->

  return {
    acceptChanges: ->
      DocumentDataService.acceptNewHistoryState()
      UndoRedoService.reset()
      PersistenceService.invalidateFile()
      return

    save: () ->
      PersistenceService.invalidateFile()

    openDrive: (progress) ->
      return PersistenceService.openFileInPicker(progress)
        .then (result)->
          name = result.file.title
          jsonStringData = result.data
          DocumentDataService.setRawData(jsonStringData)
          return Promise.resolve(result.file)

    saveNewDrive: (name, progress) ->
      return PersistenceService.saveNew({name: name, progress: progress})

    loadFile: (options) ->
      loadPromise = Promise.resolve()
      if options.path == 'demo'
        DocumentDataService.setData(demoPayments, demoAccounts, demoValues)
        loadPromise = Promise.resolve('demo')
      else if options.path == 'local'
        existingData = localStorage.getItem 'loal'
        if existingData
          DocumentDataService.setRawData(jsonStringData)
        else
          DocumentDataService.setData([], [], {})
        loadPromise = Promise.resolve('local')
      else if _.startsWith(options.path, 'drive:')
        id = options.path.substring(6)
        loadPromise = PersistenceService.loadFile({id: id, progress: options.progress})
        .then (result) ->
          name = result.file.title
          jsonStringData = result.data
          DocumentDataService.setRawData(jsonStringData)
          return Promise.resolve(name)
      else
        throw new Error('unknown path')
      return loadPromise

    authorizeInDrive: -> (cb, progress) ->
      PersistenceService.authorizeInDrive(cb, progress)

    newFile: ->
      DocumentDataService.setData([], [], {})
  }
