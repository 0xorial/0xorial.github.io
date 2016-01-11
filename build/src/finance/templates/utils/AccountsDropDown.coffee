app.directive 'accountsDropDown', ->
  return {
    restrict: 'E'
    templateUrl: 'finance/templates/utils/AccountsDropDown.html'
    scope: {
      selectedAccount: '=selectedAccount'
    }
    controller: ($scope, DataService) ->
      $scope.accounts = DataService.getAccounts()
  }
