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
    await SavingService.saveDrive($stateParams.documentPath, defer(file), progress)

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
    new Clipboard('#copy', {
      text: -> $scope.serializedData
      })

  $scope.authorizeInDrive = () ->
    await SavingService.authorizeInDrive(defer(error), progress)
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

  $scope.loadData = ->
    SavingService.loadJson($scope.serializedData)

  $scope.$on 'dataEdited', ->
    SavingService.acceptChanges()
    $scope.serializedData = SavingService.getRawData()

  $scope.new = ->
    SavingService.newFile()
