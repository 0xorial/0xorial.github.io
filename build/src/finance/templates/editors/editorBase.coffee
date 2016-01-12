
window.makeEditor = (name) ->
  app.directive name, ->
    return {
      restrict: 'E'
      templateUrl: 'finance/templates/editors/' + _.capitalize(name) + '.html'
      scope: {
        payment: '='
      }
      controller: ($scope) ->
        $scope.$watch 'payment', (p) ->
          _.augmentDatesDeep p
    }

makeEditor 'simplePayment'
makeEditor 'borrowPayment'
makeEditor 'periodicPayment'
makeEditor 'taxableIncomePayment'
