app.controller 'SerializationCtrl', (
  $scope,
  $timeout,
  $rootScope,
  DataService,
  SavingService,
  UndoRedoService,
  $state,
  $stateParams,
  $location) ->

  $scope.saveDrive = ->
    SavingService.save()

  $scope.saveDriveNew = ->
    if !$scope.driveFileName
      progress('Enter file name.')
    SavingService.saveNewDrive($scope.driveFileName, progress)
    .then (file) ->
      $state.go('.', {documentPath: 'drive:' + file.id}, {notify: false})

  $scope.canUndo = ->
    UndoRedoService.canUndo()

  $scope.canRedo = ->
    UndoRedoService.canRedo()

  $scope.undo = ->
    UndoRedoService.undo()

  $scope.redo = ->
    UndoRedoService.redo()

  $scope.$on 'rawDataChanged', ->
    $scope.serializedData = SavingService.getRawData()

  $scope.copy = ->
    blob = new Blob([$scope.serializedData], {type: "text/json;charset=utf-8"});
    saveAs(blob, $scope.title + '.json');

  $scope.authorizeInDrive = () ->
    SavingService.authorizeInDrive(progress)
    .then ->
      loadCurrentFile()

  progress = (m, showButton) ->
    $timeout ->
      $scope.$apply -> $scope.status = m
      $scope.needDriveAuthorization = showButton

  $scope.openDrive = ->
    await SavingService.openDrive(defer(error, file), progress)

  loadCurrentFile = ->
    SavingService.loadFile({path: $stateParams.documentPath, progress: progress})
    .then (file) ->
      $timeout ->
        $scope.$apply ->
          $scope.driveFileName = file.title
          $scope.isLoading = false
          $scope.status = 'Ready'

  loadCurrentFile()

  onFileChanged = (file)->
    readSingleFile(file)
    .then (contents) ->
      $scope.serializedData = contents
      SavingService.loadJson(contents)
    .then ->
      document.getElementById('file-input').value = null
      $scope.$apply()

  document.getElementById('file-input').addEventListener 'change', onFileChanged, false
  # $scope.loadData = ->


  $scope.$on 'dataEdited', ->
    SavingService.acceptChanges()
    $scope.serializedData = SavingService.getRawData()

  $scope.new = ->
    SavingService.newFile()
