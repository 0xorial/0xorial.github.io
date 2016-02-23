
window.makeEditor = (name) ->
  app.directive name, ->
    return {
      restrict: 'E'
      templateUrl: 'finance/templates/editors/' + _.capitalize(name) + '.html'
      scope: {
        payment: '='
      }
      controller: ($scope) ->
        onPaymentChanged = (p) ->
          _.augmentDatesDeep p
        $scope.$watch 'payment', onPaymentChanged
    }

makeEditor 'simplePayment'
makeEditor 'borrowPayment'
makeEditor 'periodicPayment'
makeEditor 'taxableIncomePayment'
