app.controller 'SerializationCtrl', ($scope, $timeout, $rootScope, DataService, SavingService, $state, $stateParams, $location) ->

  undoStack = []
  undoPointer = -1

  $scope.canUndo = false
  $scope.canRedo = false

  $scope.isLoading = true
  $scope.status = 'Loading...'
  progress = (m) ->
    $timeout ->
      $scope.$apply -> $scope.status = m

  SavingService.loadFile($stateParams.documentPath,
    ( (error, name) ->
      $timeout ->
        $scope.$apply ->
          $scope.driveFileName = name
          $scope.isLoading = false
          if !error
            $scope.status = 'Ready'),
    progress)

  $scope.loadData = ->

  $scope.saveData = ->

  $scope.saveDrive = ->
    await SavingService.saveDrive($stateParams.documentPath, defer(file), progress)

  $scope.saveDriveNew = ->
    if !$scope.driveFileName
      progress('Enter file name.')
    await SavingService.saveNewDrive($scope.driveFileName, defer(file), progress)
    $state.go('.', {documentPath: 'drive:' + file.id}, {notify: false})

  $scope.canUndo = ->
    undoPointer > 1

  $scope.canRedo = ->
    undoPointer < undoStack.length - 1

  $scope.undo = ->
    $scope.serializedData = undoStack[--undoPointer]

  $scope.redo = ->
    $scope.serializedData = undoStack[++undoPointer]

  $scope.$on 'dataChanged', ->
    $scope.serializedData = SavingService.saveJson()

  $scope.$watch 'serializedData', ->
    currentStackData = undoStack[undoPointer]
    if currentStackData != $scope.serializedData and $scope.serializedData
      undoStack.splice(undoPointer + 1)
      undoStack.push $scope.serializedData
      undoPointer++

    if $scope.serializedData and $scope.serializedData != SavingService.getCurrentJson()
      SavingService.loadJson($scope.serializedData)

  $scope.copy = ->
    new Clipboard('#copy', {
      text: -> $scope.serializedData
      })
