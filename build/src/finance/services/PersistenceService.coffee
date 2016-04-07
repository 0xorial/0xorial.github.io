app.service 'PersistenceService', (
  GoogleDriveSaveService,
  HistoryService,
  JsonSerializationService) ->

  serialize = () ->
    currentData = HistoryService.getData()
    return JSON.stringify(currentData, null, '  ')

  currentDriveFile = null
  progressListener = null
  throttledUpdate = ->


  return {
    setStatusListener: (listener) ->
      progressListener = listener

    invalidateFile: ->
      throttledUpdate()

    saveNew: (options) ->
      progressListener = options.progress
      localStorage.setItem('data', options.done)
      GoogleDriveSaveService.saveNew({
        name: options.name
        progress: progressListener
        data: options.data
        index: options.index
        done: options.done
        })
      update = ->
        data = serialize()
        localStorage.setItem('data', data)
        GoogleDriveSaveService.update({
          progress: progressListener
          data: data
          done: ->
          })
      throttledUpdate = _.throttle(update, 2000)

    loadFile: (options) ->
      GoogleDriveSaveService.load({
        id: options.id,
        done: options.done
        progress: progressListener
        })
  }
