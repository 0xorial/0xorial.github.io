app = angular.module('StarterApp', [
  'md.data.table'
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

app.controller 'LayoutCtrl', ($scope, $state, $stateParams) ->
  $scope.paymentsActive = ->
    return $stateParams.leftTab == '1' or $stateParams.leftTab == undefined
  $scope.accountsActive = ->
    return $stateParams.leftTab == '2'

  setTab = (param, value) ->
    p = {}
    p[param] = value
    $state.go('.', p, {notify: false})

  $scope.onPaymentsSelected = -> setTab('leftTab', '1')
  $scope.onAccountsSelected = -> setTab('leftTab', '2')

  $scope.overviewActive = ->
    return $stateParams.rightTab == '1' or $stateParams.rightTab == undefined
  $scope.transactionsActive = ->
    return $stateParams.rightTab == '2'

  $scope.onOverviewSelected = -> setTab('rightTab', '1')
  $scope.onTransactionsSelected = -> setTab('rightTab', '2')
