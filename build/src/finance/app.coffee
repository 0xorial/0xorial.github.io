app = angular.module('StarterApp', [
  'md.data.table'
  'ngMaterial'
  'ngMdIcons'
  'mdColorPicker'
  'highcharts-ng'
  'ui.router'
])

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/demo'
  $stateProvider
    .state('root', {
      url: '/:documentPath'
      templateUrl: 'state.html'
      })

window.app = app
