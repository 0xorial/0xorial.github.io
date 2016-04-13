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

  savingPromise = null
  startUpdating = ->
    update = ->
      data = serialize()
      localStorage.setItem('data', data)
      progressListener('Updated local storage.')
      return GoogleDriveSaveService.update({
        progress: progressListener
        data: data
        })
    savingPromise = Promise.resolve()
    waitAndUpdate = ->
      savingPromise = savingPromise.then ->
        update()
    throttledUpdate = _.throttle(waitAndUpdate, 2000)

  return {
    setStatusListener: (listener) ->
      progressListener = listener

    stopUpdating: ->
      if savingPromise
        savingPromise.cancel()
      throttledUpdate = ->

    invalidateFile: ->
      throttledUpdate()

    saveNew: (options) ->
      progressListener = options.progress
      localStorage.setItem('data', options.data)
      return GoogleDriveSaveService.saveNew({
        name: options.name
        progress: progressListener
        data: options.data
        index: options.index
        })
      .then (file) ->
        localStorage.setItem('data', null)
        localStorage.setItem('data:' + file[0].id, options.data)
        startUpdating()
        return Promise.resolve(file[0])

    loadFile: (options) ->
      progressListener = options.progress
      return GoogleDriveSaveService.load({
        id: options.id,
        progress: options.progress
        })
      .catch () ->
        existing = localStorage.getItem('data:' + options.id)
        if existing
          return Promise.resolve({data: existing})
        else
          throw new Error()
      .then (result) ->
        startUpdating()
        return Promise.resolve(result)
  }
