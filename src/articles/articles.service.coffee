articles = [
  {
    id: 1
    date: new Date('September 28, 2015 11:11:00"')
    title: 'My first article here'
    description: 'This is not really an article!'
  }
]

angular
  .module('StarterApp.articles')
  .service 'ArticlesService', class ArticlesService
      listArticles: ->
        return new Promise.resolve(articles)
