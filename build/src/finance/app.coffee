app = angular.module('StarterApp', [
  'ngMaterial'
  'ngMdIcons'
  'mdColorPicker'
  'highcharts-ng'
  'ui.router'
])

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/?documentPath=demo'
  $stateProvider
    .state('root', {
      url: '/?documentPath&leftTab&rightTab'
      templateUrl: 'state.html'
      })

window.app = app
