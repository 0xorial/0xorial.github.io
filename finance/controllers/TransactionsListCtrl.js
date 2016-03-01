(function() {
  app.controller('TransactionsListCtrl', function($scope, $rootScope, SimulationService, DataService) {
    var context;
    context = SimulationService.runSimulation();
    $scope.allTransactions = context.transactions;
    $scope.simulateUntil = function(transaction) {
      return $rootScope.$broadcast('enterTransaction', transaction);
    };
    $scope.simulateAll = function() {
      return $rootScope.$broadcast('enterTransaction', null);
    };
    $scope.$on('enterPayment', function(__, payment) {
      var t, _i, _len, _ref, _results;
      _ref = $scope.allTransactions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        _results.push(t.higlight = t.payment === payment);
      }
      return _results;
    });
    return $scope.$on('simulationRan', function(__, c) {
      return $scope.allTransactions = c.transactions;
    });
  });

}).call(this);
