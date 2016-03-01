(function() {
  window.makeEditor = function(name) {
    return app.directive(name, function() {
      return {
        restrict: 'E',
        templateUrl: 'finance/templates/editors/' + _.capitalize(name) + '.html',
        scope: {
          payment: '='
        },
        controller: function($scope) {
          var onPaymentChanged;
          onPaymentChanged = function(p) {
            return _.augmentDatesDeep(p);
          };
          return $scope.$watch('payment', onPaymentChanged);
        }
      };
    });
  };

  makeEditor('simplePayment');

  makeEditor('borrowPayment');

  makeEditor('periodicPayment');

  makeEditor('taxableIncomePayment');

}).call(this);
