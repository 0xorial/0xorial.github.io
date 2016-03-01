(function() {
  app.controller('PaymentsListCtrl', function($scope, $rootScope, DataService, SimulationService) {
    var convertPayment, update;
    $scope.payments = [];
    convertPayment = function(p, r) {
      var a;
      if (p.account) {
        a = {
          currency: p.account.currency,
          accountName: p.account.name,
          color: p.account.color
        };
      } else {
        a = {};
      }
      r.payment = p;
      r.amount = p.amount;
      r.currency = a.currency;
      r.accountName = a.accountName;
      r.color = a.color;
      if (p instanceof SimplePayment) {
        r.description = p.description;
        r.type = 'Simple';
        r.date = p.date.toDate();
      }
      if (p instanceof BorrowPayment) {
        r.description = p.description;
        r.type = 'Loan';
        r.date = p.date.toDate();
      }
      if (p instanceof PeriodicPayment) {
        r.description = p.description;
        r.type = 'Periodic';
        r.date = p.startDate.toDate();
      }
      if (p instanceof TaxableIncomePayment) {
        r.description = p.params.description;
        r.type = 'Income';
        return r.date = p.params.paymentDate.toDate();
      }
    };
    update = function() {
      var a, b, d, difference, fullState, i, otherPayments, p, payments, r, state, unmuted, _i, _j, _len, _len1, _ref, _ref1;
      payments = DataService.getAllPayments();
      _.merge({
        src: payments,
        dst: $scope.payments,
        make: function() {
          return {};
        },
        equals: function(x, y) {
          return x.id === y.payment.id;
        },
        assign: function(dst, src) {
          return convertPayment(src, dst);
        }
      });
      $scope.payments = _.sortBy($scope.payments, 'date');
      fullState = SimulationService.getLastSimulation().currentAccountsState;
      unmuted = DataService.getUnmutedPayments();
      _ref = $scope.payments.filter(function(pp) {
        return !pp.payment.isMuted;
      });
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        otherPayments = _.except(unmuted, function(pp) {
          return pp.id === p.payment.id;
        });
        r = SimulationService.runSimulationFor(otherPayments);
        state = r.currentAccountsState;
        difference = 0;
        _ref1 = state.accounts;
        for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
          a = _ref1[i];
          b = state.balances[i];
          d = fullState.balances[i] - b;
          difference += d;
        }
        p.effect = numeral(difference).format('+0.00');
      }
    };
    update();
    $scope.enteredPayment = function(payment) {
      return $rootScope.$broadcast('enterPayment', payment.payment);
    };
    $scope.leftPayment = function(payment) {
      return $rootScope.$broadcast('enterPayment', null);
    };
    $scope.templateFor = function(payment) {
      var x;
      x = function() {
        if (payment instanceof BorrowPayment) {
          return 'borrowPayment';
        }
        if (payment instanceof PeriodicPayment) {
          return 'periodicPayment';
        }
        if (payment instanceof TaxableIncomePayment) {
          return 'taxableIncomePayment';
        }
        return 'simplePayment';
      };
      return _.kebabCase(x(payment));
    };
    $scope.edit = function(payment) {
      payment.editPayment = payment.payment.clone();
      return payment.showEdit = true;
    };
    $scope.cancelEdit = function(payment) {
      payment.showEdit = false;
      return payment.editPayment = null;
    };
    $scope.saveEdit = function(payment) {
      payment.editPayment.assignTo(payment.payment);
      payment.editPayment = null;
      payment.showEdit = false;
      return $rootScope.$broadcast('dataChanged');
    };
    $scope["delete"] = function(payment) {
      return DataService.deletePayment(payment.payment);
    };
    $scope.mute = function(payment) {
      payment.payment.isMuted = true;
      DataService.notifyChanged();
      return update();
    };
    $scope.unmute = function(payment) {
      payment.payment.isMuted = false;
      DataService.notifyChanged();
      return update();
    };
    $scope.muteAll = function() {
      var p, _i, _len, _ref;
      _ref = $scope.payments;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        p.payment.isMuted = true;
      }
      DataService.notifyChanged();
      return update();
    };
    $scope.unmuteAll = function() {
      var p, _i, _len, _ref;
      _ref = $scope.payments;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        p.payment.isMuted = false;
      }
      DataService.notifyChanged();
      return update();
    };
    return $scope.$on('simulationRan', function(__, c) {
      return update();
    });
  });

}).call(this);
