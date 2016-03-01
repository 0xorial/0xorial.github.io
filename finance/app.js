(function() {
  var app;

  app = angular.module('StarterApp', ['ngMaterial', 'ngMdIcons', 'mdColorPicker', 'highcharts-ng', 'ui.router']);

  app.config(function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/?documentPath=demo');
    return $stateProvider.state('root', {
      url: '/?documentPath&leftTab&rightTab',
      templateUrl: 'state.html'
    });
  });

  window.app = app;

  app.controller('LayoutCtrl', function($scope, $state, $stateParams) {
    var setTab;
    $scope.paymentsActive = function() {
      return $stateParams.leftTab === '1' || $stateParams.leftTab === void 0;
    };
    $scope.accountsActive = function() {
      return $stateParams.leftTab === '2';
    };
    setTab = function(param, value) {
      var p;
      p = {};
      p[param] = value;
      return $state.go('.', p, {
        notify: false
      });
    };
    $scope.onPaymentsSelected = function() {
      return setTab('leftTab', '1');
    };
    $scope.onAccountsSelected = function() {
      return setTab('leftTab', '2');
    };
    $scope.overviewActive = function() {
      return $stateParams.rightTab === '1' || $stateParams.rightTab === void 0;
    };
    $scope.transactionsActive = function() {
      return $stateParams.rightTab === '2';
    };
    $scope.onOverviewSelected = function() {
      return setTab('rightTab', '1');
    };
    return $scope.onTransactionsSelected = function() {
      return setTab('rightTab', '2');
    };
  });

}).call(this);
