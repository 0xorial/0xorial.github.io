(function() {
  app.controller('NewPaymentCtrl', function($scope, $rootScope, DataService, $mdDialog) {
    var getFirstAccount, getVisible, hideEditor, k, paymentTypes, _fn, _scope;
    jQuery(document).on('keypress', function(e) {
      console.log(e);
      if (e.keyCode === 110) {
        $scope.showMenu();
      }
      if (e.keyCode === 115) {
        $scope.newSimplePayment(e);
      }
      if (e.keyCode === 98) {
        $scope.newBorrowPayment(e);
      }
      if (e.keyCode === 112) {
        $scope.newPeriodicPayment(e);
      }
      if (e.keyCode === 105) {
        return $scope.newTaxableIncomePayment(e);
      }
    });
    $scope.showMenu = function($mdOpenMenu, ev) {
      return $mdOpenMenu(ev);
    };
    getFirstAccount = function() {
      return DataService.getAccounts()[0];
    };
    paymentTypes = {
      simplePayment: function() {
        return new SimplePayment(getFirstAccount(), moment(), 100, 'description', false, 1);
      },
      borrowPayment: function() {
        return new BorrowPayment(getFirstAccount(), moment(), moment(), 100, 'description');
      },
      periodicPayment: function() {
        return new PeriodicPayment(getFirstAccount(), moment(), moment(), {
          quantity: 1,
          units: 'months'
        }, 100, 'description');
      },
      taxableIncomePayment: function() {
        return new TaxableIncomePayment(getFirstAccount(), 100);
      }
    };
    $scope.anyVisible = false;
    $scope.visibility = {};
    $scope.template = {};
    _scope = $scope;
    _fn = function(k) {
      $scope.template[k] = new paymentTypes[k];
      $scope.visibility[k] = false;
      return $scope[_.camelCase('new_' + k)] = function(ev) {
        var kk;
        for (kk in $scope.visibility) {
          $scope.visibility[kk] = false;
        }
        $scope.visibility[k] = true;
        return $mdDialog.show({
          controller: function($scope, $mdDialog) {
            $scope.template = _scope.template;
            $scope.visibility = _scope.visibility;
            $scope.ok = function() {
              $mdDialog.hide();
              return _scope.addPayment();
            };
            return $scope.cancel = function() {
              return $mdDialog.cancel();
            };
          },
          templateUrl: 'dialog.html',
          parent: angular.element(document.body),
          targetEvent: ev,
          clickOutsideToClose: true
        });
      };
    };
    for (k in paymentTypes) {
      _fn(k);
    }
    getVisible = function() {
      var kk;
      for (kk in $scope.visibility) {
        if ($scope.visibility[kk]) {
          return kk;
        }
      }
      return null;
    };
    hideEditor = function() {
      var kk;
      for (kk in $scope.visibility) {
        $scope.visibility[kk] = false;
      }
      return $scope.anyVisible = false;
    };
    $scope.addPayment = function() {
      var payment;
      k = getVisible();
      payment = $scope.template[k];
      DataService.addPayment(payment);
      $scope.template[k] = new paymentTypes[k];
      return hideEditor();
    };
  });

}).call(this);
