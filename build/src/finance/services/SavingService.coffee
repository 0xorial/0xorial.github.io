app.service 'SavingService', (
  DocumentDataService,
  PersistenceService) ->

  return {
    acceptChanges: ->
      UndoRedoService.reset()
      return

    save: () ->
      PersistenceService.invalidateFile()

    openDrive: (done, progress) ->
      # GoogleDriveSaveService.showPicker(done, progress)
      # saveContinuously(null, done, progress)

    saveNewDrive: (name, progress) ->
      data = DocumentDataService.getRawData()
      return PersistenceService.saveNew({name: name, data: data, progress: progress})

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
          name = result.file.name
          jsonStringData = result.data
          DocumentDataService.setRawData(jsonStringData)

      else
        throw new Error('unknown path')
      return loadPromise

    authorizeInDrive: -> (cb, progress) ->
      GoogleDriveSaveService.authorizeInDrive(cb, progress)

    newFile: ->
      DocumentDataService.setData([], [], {})
  }
