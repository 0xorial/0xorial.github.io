app.controller 'ValuesCtrl', ($scope, $rootScope, DataService, $mdDialog) ->
  $scope.showValues = ->
    $mdDialog.show({
      controller: ($scope, $mdDialog) ->
        values = []
        dataValues = DataService.getValues()
        for key, value of dataValues
          values.push {name: key, value: value}
        $scope.values = values
        $scope.delete = (name) ->
          _.remove($scope.values, (p) -> p.name == name)
        $scope.new = ->
          $scope.values.push({name: '', value: ''})

        $scope.ok = ->
          $mdDialog.hide()
          dataValues = {}
          for v in $scope.values
            dataValues[v.name] = v.value
          DataService.setValues(dataValues)
          DataService.notifyEdited()
        $scope.cancel = ->
          $mdDialog.cancel()


      templateUrl: 'values-dialog.html',
      parent: angular.element(document.body),
      clickOutsideToClose:true
    })
