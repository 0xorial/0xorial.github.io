app.directive 'directive', ($compile) ->
  return {
    restrict: 'A'
    replace: true
    template: ''
    link: ($scope, element, attributes) ->
      $scope.$watch attributes.directive, (value) ->
        attr = []
        for k of attributes.$attr
          if k != 'directive'
            attr.push attributes.$attr[k] + '="' + attributes[k] + '"'
        attributesString = attr.join ' '
        element.append($compile('<' + value + ' ' + attributesString + '></' + value + '>')($scope))
  }
