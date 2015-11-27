app = angular.module('StarterApp', [
  'ui.router'
  'ngMaterial'
  'ngMdIcons'
])

app.controller 'AppCtrl', ($rootScope, $scope, $timeout) ->

i = [{text: 'sssdfsd'}]

app.controller 'NewMemoCtrl', ($scope) ->
  $scope.memoText = ''
  $scope.addNewMemo = ->
    i.push { text: $scope.memoText }
    $scope.memoText = ''


app.controller 'MemoListCtrl', ($scope) ->
  $scope.memos = i

