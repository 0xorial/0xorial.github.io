app = angular.module('StarterApp', [
  'md.data.table'
  'ngMaterial'
  'ngMdIcons'
  'mdColorPicker'
])

app.controller 'AppCtrl', ($rootScope, $scope, $timeout) ->

window.app = app
