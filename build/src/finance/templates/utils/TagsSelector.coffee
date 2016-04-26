app.directive 'tagsSelector', ->
  return {
    restrict: 'E'
    templateUrl: 'finance/templates/utils/TagsSelector.html'
    scope: {
      payment: '=payment'
    }
    controller: ($scope) ->

  }
