(function() {
  var DatesAggregator, ScheduleGenerator, app, earliest, extremum, getItemsFromGenerators, globalMemos;

  app = angular.module('StarterApp', ['ngMaterial']);

  app.controller('AppCtrl', function($rootScope, $scope, $timeout) {});

  globalMemos = [
    {
      repeatDates: [],
      learnDate: new Date(2015, 10, 11),
      text: 'French'
    }, {
      repeatDates: [],
      learnDate: new Date(2015, 10, 27),
      text: 'Math'
    }, {
      repeatDates: [],
      learnDate: new Date(2015, 1, 15),
      text: 'Dutch'
    }, {
      repeatDates: [],
      learnDate: new Date(2014, 10, 15),
      text: 'Poem'
    }
  ];

  ScheduleGenerator = (function() {
    function ScheduleGenerator(learnDate) {
      this.learnDate = learnDate;
      this.spaces = [1, 3, 7, 13].map(function(d) {
        return moment.duration(d, 'days');
      });
      this.longTermRepeatDelay = moment.duration(30, 'days');
      this.nextDateIndex = 0;
      this.learnDate = moment(this.learnDate);
      this.lastSpecialDate = this.learnDate.clone();
      this.previousDate = this.learnDate.clone();
    }

    ScheduleGenerator.prototype.peekNextDate = function() {
      var delay;
      if (this.nextDateIndex >= this.spaces.length) {
        delay = this.longTermRepeatDelay;
      } else {
        delay = this.spaces[this.nextDateIndex];
      }
      return this.previousDate.clone().add(delay);
    };

    ScheduleGenerator.prototype._advance = function(date) {
      this.nextDateIndex++;
      return this.previousDate = date;
    };

    ScheduleGenerator.prototype.getNextDate = function() {
      var next;
      next = this.peekNextDate();
      this._advance(next);
      return next;
    };

    return ScheduleGenerator;

  })();

  extremum = function(collection, comparator) {
    var i, index, r, rIndex, _i, _len;
    r = _.first(collection);
    rIndex = 0;
    index = 0;
    for (_i = 0, _len = collection.length; _i < _len; _i++) {
      i = collection[_i];
      if (comparator(i, r)) {
        r = i;
        rIndex = index;
      }
      index++;
    }
    return rIndex;
  };

  earliest = function(collection, selector) {
    return extremum(collection, function(i, extr) {
      return selector(i).isBefore(selector(extr));
    });
  };

  DatesAggregator = (function() {
    function DatesAggregator(generators) {
      this.generators = generators;
      this.nextItems = this.generators.map(function(g) {
        return g.getNextDate();
      });
    }

    DatesAggregator.prototype.peekNextDate = function() {
      var date, nextIndex;
      nextIndex = earliest(this.nextItems, function(i) {
        return i;
      });
      date = this.nextItems[nextIndex];
      return {
        date: date,
        generator: this.generators[nextIndex],
        index: nextIndex
      };
    };

    DatesAggregator.prototype.advance = function(next) {
      return this.nextItems[next.index] = this.generators[next.index].getNextDate();
    };

    return DatesAggregator;

  })();

  getItemsFromGenerators = function(aggregator, till) {
    var next, result;
    result = [];
    while (true) {
      next = aggregator.peekNextDate();
      if (next.date.isBefore(till)) {
        result.push(next);
        aggregator.advance(next);
      } else {
        break;
      }
    }
    return result.map(function(g) {
      return {
        memo: g.generator.memo,
        date: g.date.toDate()
      };
    });
  };

  app.controller('NewMemoCtrl', function($scope, MemoService) {
    $scope.memoText = '';
    return $scope.addNewMemo = function() {
      var x;
      x = MemoService.getMemos();
      x.push({
        text: $scope.memoText,
        learnDate: new Date()
      });
      return $scope.memoText = '';
    };
  });

  app.controller('MemoListCtrl', function($scope, MemoService) {
    return $scope.memos = MemoService.getMemos();
  });

  app.controller('MemoScheduleCtrl', function($scope, MemoService) {
    var recalculate;
    recalculate = function() {
      var aggregator, generators, memos, monthEnd, todayEnd, todayStart, weekEnd;
      todayStart = moment().startOf('day');
      todayEnd = todayStart.clone().add(1, 'day');
      weekEnd = todayEnd.clone().add(1, 'week');
      monthEnd = todayEnd.clone().add(1, 'month');
      memos = MemoService.getMemos();
      generators = memos.map(function(memo) {
        var g;
        g = new ScheduleGenerator(memo.learnDate);
        g.memo = memo;
        return g;
      });
      aggregator = new DatesAggregator(generators);
      getItemsFromGenerators(aggregator, todayStart);
      $scope.todayItems = getItemsFromGenerators(aggregator, todayEnd);
      $scope.weekItems = getItemsFromGenerators(aggregator, weekEnd);
      return $scope.monthItems = getItemsFromGenerators(aggregator, monthEnd);
    };
    return recalculate();
  });

  app.service('MemoService', function() {
    this.getMemos = function() {
      return globalMemos;
    };
  });

}).call(this);
