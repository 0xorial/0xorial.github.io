app.directive 'tagsArray', ->
    return {
        restrict: 'A',
        require: 'ngModel',
        link: (scope, element, attr, ngModel) ->
          fromArray = (array) ->
            return (array || []).join(' ')

          toArray = (text) ->
            return (text || '').split(' ')

          ngModel.$parsers.push(toArray);
          ngModel.$formatters.push(fromArray);
    }
