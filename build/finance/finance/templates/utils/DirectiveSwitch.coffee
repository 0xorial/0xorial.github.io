cache = {}

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
        str = '<' + value + ' ' + attributesString + '></' + value + '>'
        if !cache[str]
          cache[str] = $compile(str)
        compiled = cache[str]
        compiled $scope, (clonedElement, scope) ->
          element.append(clonedElement)
  }
