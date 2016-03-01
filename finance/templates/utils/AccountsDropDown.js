(function() {
  app.directive('accountsDropDown', function() {
    return {
      restrict: 'E',
      templateUrl: 'finance/templates/utils/AccountsDropDown.html',
      scope: {
        selectedAccount: '=selectedAccount'
      },
      controller: function($scope, DataService) {
        $scope.accounts = DataService.getAccounts();
        return $scope.$on('dataChanged', function() {
          return $scope.accounts = DataService.getAccounts();
        });
      }
    };
  });

}).call(this);
