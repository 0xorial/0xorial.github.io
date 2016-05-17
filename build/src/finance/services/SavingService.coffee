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

    save: (progress) ->
      PersistenceService.save({progress: progress})

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
      setDemoData = ->
        DocumentDataService.setData(demoPayments, demoAccounts, demoValues)
        loadPromise = Promise.resolve('demo')

      if options.path == 'demo'
        setDemoData()
      else if options.path == 'local'
        existingData = PersistenceService.tryLoadLocal()
        if existingData
          DocumentDataService.setRawData(existingData)
          loadPromise = Promise.resolve('local')
        else
          setDemoData()
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
