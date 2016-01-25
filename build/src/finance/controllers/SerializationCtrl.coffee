app.controller 'SerializationCtrl', ($scope, $rootScope, DataService, SavingService, $state, $stateParams, $location) ->

  # $state.go('.', {documentPath: 'xxx'})
  SavingService.loadFile($stateParams.documentPath)

  $scope.loadData = ->
    deserialize()
  $scope.saveData = ->
    serialize()

  $scope.saveDrive = ->

  $scope.$on 'dataChanged', ->
    $scope.serializedData = SavingService.saveJson()

  $scope.$watch 'serializedData', ->
    if $scope.serializedData
      SavingService.loadJson($scope.serializedData)

  $scope.copy = ->
    serialize()
    new Clipboard('#copy', {
      text: -> $scope.serializedData
      })
