app.controller 'SerializationCtrl', ($scope, $rootScope, DataService, SavingService, $state, $stateParams, $location) ->

  undoStack = []
  undoPointer = -1

  $scope.canUndo = false
  $scope.canRedo = false

  SavingService.loadFile($stateParams.documentPath)

  $scope.loadData = ->
    deserialize()
  $scope.saveData = ->
    serialize()

  $scope.saveDrive = ->

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

    if $scope.serializedData
      SavingService.loadJson($scope.serializedData)

  $scope.copy = ->
    new Clipboard('#copy', {
      text: -> $scope.serializedData
      })
