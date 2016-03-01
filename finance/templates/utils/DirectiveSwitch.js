(function() {
  var cache;

  cache = {};

  app.directive('directive', function($compile) {
    return {
      restrict: 'A',
      replace: true,
      template: '',
      link: function($scope, element, attributes) {
        return $scope.$watch(attributes.directive, function(value) {
          var attr, attributesString, compiled, k, str;
          attr = [];
          for (k in attributes.$attr) {
            if (k !== 'directive') {
              attr.push(attributes.$attr[k] + '="' + attributes[k] + '"');
            }
          }
          attributesString = attr.join(' ');
          str = '<' + value + ' ' + attributesString + '></' + value + '>';
          if (!cache[str]) {
            cache[str] = $compile(str);
          }
          compiled = cache[str];
          return compiled($scope, function(clonedElement, scope) {
            return element.append(clonedElement);
          });
        });
      }
    };
  });

}).call(this);
