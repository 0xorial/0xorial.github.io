app.service 'GoogleDriveSaveService', (GoogleDriveApiService) ->

  currentFile = null

  return {
    saveNew: (options) ->
      return GoogleDriveApiService.newFile(options.name, options.data, options.index, options.progress)
      .then (file) ->
        currentFile = file
    update: (options) ->
      if !currentFile
        throw new Error()
      await GoogleDriveApiService.updateFile(currentFile.id, options.data, options.index, options.done, options.progress)
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
