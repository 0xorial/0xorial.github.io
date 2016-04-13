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
      return GoogleDriveApiService.updateFile({id: currentFile.id, data: options.data, index: options.index, progress: options.progress})
    load: (options) ->
      return GoogleDriveApiService.loadFile({id: options.id, progress: options.progress})
      .then (result) ->
        currentFile = result.file
        return Promise.resolve(result)
    showPicker: ->
      throw new Error('not implemented')
      await GoogleDriveApiService.showPicker(defer(file))
      currentFile = file
      return 'data'
  }
