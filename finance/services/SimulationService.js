(function() {
  app.service('SimulationService', function($rootScope, DataService) {
    var lastSimulation, runSimulation, runSimulationGlobal;
    lastSimulation = null;
    $rootScope.$on('dataChanged', function() {
      return runSimulationGlobal();
    });
    runSimulationGlobal = function() {
      var payments;
      payments = DataService.getUnmutedPayments();
      lastSimulation = runSimulation(payments);
      return $rootScope.$broadcast('simulationRan', lastSimulation);
    };
    runSimulation = function(payments) {
      var accounts, context, p, t, tt, _i, _j, _len, _len1;
      accounts = DataService.getAccounts();
      context = new SimulationContext(accounts);
      for (_i = 0, _len = payments.length; _i < _len; _i++) {
        p = payments[_i];
        p.getTransactions(context);
      }
      t = new BeTaxSystem();
      t.calculate(null, payments, context);
      context.executeTransactions();
      tt = context.transactions;
      for (_j = 0, _len1 = tt.length; _j < _len1; _j++) {
        t = tt[_j];
        t.amount = t.amount;
        t.jsDate = t.date.toDate();
        t.color = t.account.color;
      }
      return context;
    };
    runSimulationGlobal();
    return {
      runSimulationFor: function(payments) {
        return runSimulation(payments);
      },
      runSimulation: function() {
        runSimulationGlobal();
        return lastSimulation;
      },
      getLastSimulation: function() {
        return lastSimulation;
      }
    };
  });

}).call(this);
