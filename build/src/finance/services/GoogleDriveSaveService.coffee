app.service 'GoogleDriveSaveService', (GoogleDriveApiService) ->

  currentFile = null

  return {
    saveNew: (options) ->
      await GoogleDriveApiService.newFile(options.name, options.data, options.index, defer(file), options.progress)
      currentFile = file
      options.done()
    update: (options) ->
      if !currentFile
        throw new Error()
      await GoogleDriveApiService.updateFile(currentFile.id, options.data, options.index, options.done, options.progress)
    load: (options) ->
      await GoogleDriveApiService.loadFile(options.id, defer(error, file, data))
      currentFile = file
      options.done(error, file, data)
    showPicker: ->
      throw new Error('not implemented')
      await GoogleDriveApiService.showPicker(defer(file))
      currentFile = file
      return 'data'
  }
