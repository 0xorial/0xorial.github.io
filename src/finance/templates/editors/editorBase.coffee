
window.makeEditor = (name) ->
  app.directive name, ->
    return {
      restrict: 'E'
      templateUrl: 'finance/templates/editors/' + _.capitalize(name) + '.html'
      scope: {
        payment: '='
      }
      controller: ($scope) ->
        _.augmentDatesDeep $scope.payment
    }

makeEditor 'simplePayment'
makeEditor 'borrowPayment'
makeEditor 'periodicPayment'
makeEditor 'taxableIncomePayment'
