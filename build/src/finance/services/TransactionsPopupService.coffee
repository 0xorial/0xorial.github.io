app.service 'TransactionsPopupService', ($mdDialog) ->
  show = (transactions) ->
    $mdDialog.show({
      controller: ($scope, $mdDialog) ->
        $scope.transactions = transactions
        $scope.ok = ->
          $mdDialog.hide()

      templateUrl: 'finance/controllers/TransactionsList.html',
      parent: angular.element(document.body),
      # targetEvent: ev,
      clickOutsideToClose:true
    })

  return {
    show: show
  }
