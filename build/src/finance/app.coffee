app = angular.module('StarterApp', [
  'ngMaterial'
  'ngMdIcons'
  'mdColorPicker'
  'ui.router'
  'keyboard'
])

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/?documentPath=demo'
  $stateProvider
    .state('root', {
      url: '/?documentPath&leftTab&rightTab'
      templateUrl: 'state.html'
      })

window.app = app

Promise.config({
  cancellation: true
  })
