app.directive 'borrowPament', ->
  return {
    restrict: 'E'
    scope: {
      payment: '='
    }
    controller: -> ($scope, DataService) ->
      #$scope.payment = _.assign({}, $scope.p.payment)
      $scope.payment.date = $scope.payment.date.toDate()
      $scope.payment.returnDate = $scope.payment.returnDate.toDate()
      $scope.p.update = ->
        _.assign(@payment, $scope.payment)
        @payment.date = moment(@payment.date)
        @payment.returnDate = moment(@payment.returnDate)
  }
