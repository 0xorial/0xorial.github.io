app = angular.module('StarterApp', [
  'ui.router'
  'ngMaterial'
  'ngMdIcons'
  'StarterApp.articles'
])

.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise("/list")

  $stateProvider
    .state('list',{
      url: '/list',
      templateUrl: 'articles/list.html'
      })
    .state('view', {
      url: '/article/:articleId',
      templateUrl: (stateParams) -> 'articles/content/' + stateParams.articleId + '.html'
      })

app.controller 'AppCtrl', ($rootScope, $scope, $timeout) ->
  $scope.title = 'My articles!'

