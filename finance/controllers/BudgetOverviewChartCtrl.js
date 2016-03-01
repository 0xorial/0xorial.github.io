(function() {
  app.controller('BudgetOverviewChartCtrl', function($scope, SimulationService, DataService) {
    var update;
    $scope.$watch('accounts', (function() {
      return update();
    }), true);
    $scope.accounts = [];
    update = function() {
      var a, account, allTransactionsByDate, balance, context, d, data, dateTransactions, labels, lastTransaction, series, sum, sumData, t, transactions, transactionsByAccount, transactionsByDate, transactionsToProcess;
      _.merge({
        src: DataService.getAccounts(),
        dst: $scope.accounts,
        make: function() {
          return {
            isSelected: true
          };
        },
        equals: function(x, y) {
          return x.id === y.id;
        },
        assign: function(proxy, account) {
          proxy.id = account.id;
          proxy.name = account.name;
          proxy.color = account.color;
          return proxy.account = account;
        }
      });
      context = SimulationService.getLastSimulation();
      if (!context) {
        context = SimulationService.runSimulation();
      }
      transactionsToProcess = context.transactions.filter(function(t) {
        return _.find($scope.accounts, {
          account: t.account
        }).isSelected;
      });
      transactionsByAccount = _.groupBy(transactionsToProcess, function(t) {
        return t.account.name;
      });
      labels = [];
      series = [];
      for (a in transactionsByAccount) {
        transactions = transactionsByAccount[a];
        account = transactions[0].account;
        data = [];
        transactionsByDate = _.groupBy(transactions, function(t) {
          return t.date.valueOf();
        });
        for (d in transactionsByDate) {
          dateTransactions = transactionsByDate[d];
          sortTransactions(dateTransactions);
          t = _.last(dateTransactions);
          balance = t.accountState.getAccountBalance(t.account);
          data.push({
            transactions: dateTransactions,
            description: t.description,
            amount: t.amount,
            x: t.date.valueOf(),
            y: balance
          });
        }
        series.push({
          color: tinycolor(account.color).toHexString(),
          name: account.name,
          data: data
        });
      }
      sumData = [];
      allTransactionsByDate = _.groupBy(transactionsToProcess, function(t) {
        return t.date.valueOf();
      });
      for (d in allTransactionsByDate) {
        transactions = allTransactionsByDate[d];
        sortTransactions(transactions);
        lastTransaction = _.last(transactions);
        account = lastTransaction.account;
        sum = _.sum(lastTransaction.accountState.balances);
        sumData.push({
          x: lastTransaction.date.valueOf(),
          y: sum,
          amount: sum,
          description: 'sum',
          accountState: lastTransaction.accountState
        });
      }
      series.push({
        color: tinycolor('red').toHexString(),
        name: 'Sum',
        data: sumData
      });
      return $scope.chartConfig = {
        useHighStocks: true,
        options: {
          chart: {
            type: 'line',
            xAxis: {
              type: 'datetime'
            }
          },
          rangeSelctor: {
            selected: 0
          },
          navigator: {
            enabled: true,
            series: {
              data: sumData
            }
          },
          tooltip: {
            useHTML: true,
            formatter: function() {
              var accountPoints, i, point, result, sumPoint, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
              result = '';
              result += moment(this.x).format('DD MMMM YYYY') + '</br>';
              sumPoint = _.find(this.points, function(p) {
                return p.point.accountState;
              }).point;
              result += "<span style='color:red'>TOTAL:</span>" + sumPoint.y + '</br>';
              _ref = sumPoint.accountState.accounts;
              for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
                a = _ref[i];
                balance = sumPoint.accountState.balances[i];
                result += ("<span style='color: " + a.color + "; margin-top: 10px; display:inline-block'>") + a.name + '</span>: ' + balance + ' ' + a.currency + '</br>';
                accountPoints = this.points.filter(function(p) {
                  return p.point.transactions && p.point.transactions.find(function(t) {
                    return t.account.id === a.id;
                  });
                });
                for (_j = 0, _len1 = accountPoints.length; _j < _len1; _j++) {
                  point = accountPoints[_j];
                  _ref1 = point.point.transactions;
                  for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                    t = _ref1[_k];
                    result += "<span style='width:20px; display:inline-block;'></span>" + t.description + ': ' + t.amount + '</br>';
                  }
                }
              }
              return result;
            }
          },
          func: function(chart) {
            return chart.redraw();
          }
        },
        series: series,
        size: {
          height: 400
        }
      };
    };
    update();
    return $scope.$on('simulationRan', function(__, c) {
      return update();
    });
  });

}).call(this);
