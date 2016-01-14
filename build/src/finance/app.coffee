app = angular.module('StarterApp', [
  'md.data.table'
  'ngMaterial'
  'ngMdIcons'
  'mdColorPicker'
  # 'ui.router'
])

app.config () ->
  # $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
  # $locationProvider.html5Mode(true)
  # $urlRouterProvider.otherwise '/state'
  # $stateProvider
  #   .state('root', {
  #     url: '/state'
  #     templateUrl: 'state.html'
  #     })

window.app = app
