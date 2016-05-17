app.controller 'SerializationCtrl', (
  $scope,
  $timeout,
  $rootScope,
  DataService,
  SavingService,
  UndoRedoService,
  DocumentDataService,
  $state,
  $stateParams,
  $location) ->

  progress = (m, showButton) ->
    $timeout ->
      $scope.$apply -> $scope.status = m
      $scope.needDriveAuthorization = showButton

  $scope.save = ->
    SavingService.save(progress)

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

  $scope.download = ->
    blob = new Blob([DocumentDataService.getRawData()], {type: "text/json;charset=utf-8"});
    saveAs(blob, $scope.title + '.json');

  onFileChanged = (file)->
    readSingleFile(file)
    .then (contents) ->
      DocumentDataService.setRawData(contents)
    .then ->
      document.getElementById('file-input').value = null
      $scope.$apply()

  document.getElementById('file-input').addEventListener 'change', onFileChanged, false

  $scope.authorizeInDrive = () ->
    SavingService.authorizeInDrive(progress)
    .then ->
      loadCurrentFile()

  $scope.openDrive = ->
    SavingService.openDrive(progress)
    .then (file) ->
      $state.go('.', {documentPath: 'drive:' + file.id}, {notify: false})
      $timeout ->
        $scope.$apply ->
          $scope.driveFileName = file.title
          $scope.isLoading = false
          $scope.status = 'Ready'

  loadCurrentFile = ->
    SavingService.loadFile({path: $stateParams.documentPath, progress: progress})
    .then (file) ->
      $timeout ->
        $scope.$apply ->
          $scope.driveFileName = file
          $scope.isLoading = false
          $scope.status = 'Ready'
          $rootScope.$broadcast 'dataLoaded'

  loadCurrentFile()

  $scope.$on 'dataEdited', ->
    SavingService.acceptChanges()

  $scope.new = ->
    SavingService.newFile()
    $state.go('.', {documentPath: 'local'}, {notify: false})
