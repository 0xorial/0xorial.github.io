angular
  .module('StarterApp.articles')
  .controller 'ArticlesListCtrl', ($rootScope, $scope, $timeout, $state, ArticlesService) ->
      $scope.articles = []
      ArticlesService.listArticles()
      .then (articles) ->
        $scope.articles = articles

      $scope.viewArticle = (article) ->
        $state.go('view', {articleId: article.id})


