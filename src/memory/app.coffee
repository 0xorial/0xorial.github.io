app = angular.module('StarterApp', [
  'ngMaterial'
])

app.controller 'AppCtrl', ($rootScope, $scope, $timeout) ->

globalMemos = [
  {repeatDates: [], learnDate: new Date(2015, 10, 11), text: 'French'}
  {repeatDates: [], learnDate: new Date(2015, 10, 27), text: 'Math'}
  {repeatDates: [], learnDate: new Date(2015, 1, 15), text: 'Dutch'}
  {repeatDates: [], learnDate: new Date(2014, 10, 15), text: 'Poem'}
]

class ScheduleGenerator
  constructor: (@learnDate) ->
    @spaces = [1,3,7,13].map (d) -> moment.duration(d, 'days')
    @longTermRepeatDelay = moment.duration(30, 'days')
    @nextDateIndex = 0
    @learnDate = moment(@learnDate)
    @lastSpecialDate = @learnDate.clone()
    @previousDate = @learnDate.clone()

  peekNextDate: ->
    if @nextDateIndex >= @spaces.length
      delay = @longTermRepeatDelay
    else
      delay = @spaces[@nextDateIndex]
    return @previousDate.clone().add(delay)

  _advance: (date) ->
    @nextDateIndex++
    @previousDate = date

  getNextDate: ->
    next = @peekNextDate()
    @_advance(next)
    return next

extremum = (collection, comparator) ->
  r = _.first(collection)
  rIndex = 0
  index = 0
  for i in collection
    if comparator(i, r)
      r = i
      rIndex = index
    index++
  return rIndex

earliest = (collection, selector) ->
  return extremum collection, (i, extr) ->
    return selector(i).isBefore(selector(extr))

class DatesAggregator
  constructor: (@generators) ->
    @nextItems = @generators.map (g) -> g.getNextDate()

  peekNextDate: ->
    nextIndex = earliest(@nextItems, (i) -> i)
    date = @nextItems[nextIndex]
    return { date: date, generator: @generators[nextIndex], index: nextIndex }

  advance: (next)->
    @nextItems[next.index] = @generators[next.index].getNextDate()

getItemsFromGenerators = (aggregator, till) ->
  result = []
  while true
    next = aggregator.peekNextDate()
    if next.date.isBefore(till)
      result.push(next)
      aggregator.advance(next)
    else
      break
  return result.map (g) -> {memo: g.generator.memo, date: g.date.toDate() }

app.controller 'NewMemoCtrl', ($scope, MemoService) ->
  $scope.memoText = ''
  $scope.addNewMemo = ->
    x = MemoService.getMemos()
    x.push { text: $scope.memoText, learnDate: new Date() }
    $scope.memoText = ''


app.controller 'MemoListCtrl', ($scope, MemoService) ->
  $scope.memos = MemoService.getMemos()

app.controller 'MemoScheduleCtrl', ($scope, MemoService) ->

  recalculate = ->
    todayStart = moment().startOf('day')
    todayEnd = todayStart.clone().add(1, 'day')
    weekEnd = todayEnd.clone().add(1, 'week')
    monthEnd = todayEnd.clone().add(1, 'month')


    memos = MemoService.getMemos()

    generators = memos.map (memo) ->
      g = new ScheduleGenerator(memo.learnDate)
      g.memo = memo
      return g
    aggregator = new DatesAggregator(generators)

    getItemsFromGenerators(aggregator, todayStart)
    $scope.todayItems = getItemsFromGenerators(aggregator, todayEnd)
    $scope.weekItems = getItemsFromGenerators(aggregator, weekEnd)
    $scope.monthItems = getItemsFromGenerators(aggregator, monthEnd)

  recalculate()

app.service 'MemoService', ->
  this.getMemos = ->
    return globalMemos
  return
