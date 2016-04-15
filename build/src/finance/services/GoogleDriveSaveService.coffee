app.service 'GoogleDriveSaveService', (GoogleDriveApiService) ->

  currentFile = null

  return {
    saveNew: (options) ->
      return GoogleDriveApiService.newFile(options)
      .then (file) ->
        currentFile = file
    update: (options) ->
      if !currentFile
        throw new Error()
      return GoogleDriveApiService.updateFile(options)
    load: (options) ->
      return GoogleDriveApiService.loadFile({id: options.id, progress: options.progress})
      .then (result) ->
        currentFile = result.file
        return Promise.resolve(result)
    showPicker: (options) ->
      GoogleDriveApiService.showPicker(options.progress)
      .then (result) ->
        currentFile = result.file
        return Promise.resolve(result)
  }
