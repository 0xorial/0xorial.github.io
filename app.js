(function() {
  var app;

  app = angular.module('StarterApp', ['ui.router', 'ngMaterial', 'ngMdIcons', 'StarterApp.articles']).config(function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/list");
    return $stateProvider.state('list', {
      url: '/list',
      templateUrl: 'articles/list.html'
    }).state('view', {
      url: '/article/:articleId',
      templateUrl: function(stateParams) {
        return 'articles/content/' + stateParams.articleId + '.html';
      }
    });
  });

  app.controller('AppCtrl', function($rootScope, $scope, $timeout) {
    return $scope.title = 'My articles!';
  });

}).call(this);
