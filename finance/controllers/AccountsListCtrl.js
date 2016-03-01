(function() {
  app.controller('AccountsListCtrl', function($scope, SimulationService, DataService) {
    var context, stateConvert, stateMerge, transaction, update;
    $scope.autoSelect = true;
    $scope["delete"] = function(account) {
      return DataService.deleteAccount(account.account);
    };
    $scope.add = function() {
      var currency, name;
      name = $scope.newAccountName;
      currency = $scope.newAccountCurrency;
      DataService.addAccount(new Account(currency, name, 'white'));
      $scope.newAccountName = '';
      return $scope.newAccountCurrency = '';
    };
    stateConvert = function(state) {
      var acc;
      acc = _.zip(state.accounts, state.balances).map(function(a) {
        return {
          account: a[0],
          balance: a[1]
        };
      });
      return acc;
    };
    stateMerge = function(state) {
      var b, index, _i, _len, _ref;
      _ref = state.balances;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        b = _ref[index];
        $scope.accounts[index].balance = b;
      }
    };
    context = SimulationService.getLastSimulation();
    transaction = null;
    update = function() {
      var date, lastSimulatedTransaction, state;
      if (!context) {
        return;
      }
      state = context.currentAccountsState;
      lastSimulatedTransaction = _.last(context.transactions);
      if (lastSimulatedTransaction) {
        date = lastSimulatedTransaction.date;
      } else {
        date = moment();
      }
      if (transaction) {
        state = transaction.accountState;
        date = transaction.date;
      }
      $scope.accounts = stateConvert(state);
      return $scope.date = date.toDate();
    };
    update();
    $scope.$on('dataChanged', function() {
      return update();
    });
    $scope.$on('simulationRan', function(__, c) {
      context = c;
      return update();
    });
    return $scope.$on('enterTransaction', function(__, t) {
      if (!$scope.autoSelect) {
        return;
      }
      transaction = t;
      return update();
    });
  });

}).call(this);
