app.controller 'BudgetOverviewChartCtrl', ($scope, SimulationService, DataService) ->

  $scope.$watch 'accounts', ( -> update()), true
  $scope.accounts = []

  update = ->

    _.merge {
      src: DataService.getAccounts()
      dst: $scope.accounts
      make: -> {isSelected: true}
      equals: (x, y) -> x.id == y.id
      assign: (proxy, account) ->
        proxy.id = account.id
        proxy.name = account.name
        proxy.color = account.color
        proxy.account = account
    }
    
    context = SimulationService.getLastSimulation()
    if !context
      context = SimulationService.runSimulation()

    transactionsToProcess = context.transactions.filter (t) ->
      _.find($scope.accounts, {account: t.account}).isSelected

    transactionsByAccount = _.groupBy(transactionsToProcess, (t) -> t.account.name)

    labels = []
    series = []

    for a of transactionsByAccount
      transactions = transactionsByAccount[a]
      account = transactions[0].account
      data = []
      transactionsByDate = _.groupBy(transactions, (t) -> t.date.valueOf())
      for d of transactionsByDate
        dateTransactions = transactionsByDate[d]
        sortTransactions(dateTransactions)
        t = _.last(dateTransactions)
        balance = t.accountState.getAccountBalance(t.account)
        data.push({
          transactions: dateTransactions,
          description: t.description,
          amount: t.amount
          x: t.date.valueOf(),
          y: balance})

      series.push({
        color: tinycolor(account.color).toHexString()
        name: account.name
        data: data
      })

    sumData = []
    allTransactionsByDate = _.groupBy(transactionsToProcess, (t) -> t.date.valueOf())
    for d of allTransactionsByDate
      transactions = allTransactionsByDate[d]
      sortTransactions(transactions)
      lastTransaction = _.last(transactions)
      account = lastTransaction.account
      sum = _.sum(lastTransaction.accountState.balances)

      sumData.push({
        x: lastTransaction.date.valueOf()
        y: sum
        amount: sum
        description: 'sum'
        accountState: lastTransaction.accountState
        })

    series.push({
      color: tinycolor('red').toHexString()
      name: 'Sum'
      data: sumData
    })

    $scope.chartConfig = {
      useHighStocks: true
      options:
        chart:
          type: 'line'
          xAxis:
            type: 'datetime'
        rangeSelctor:
          selected:0
        navigator:
          enabled: true
          series:
            data: sumData
        tooltip:
          useHTML: true
          formatter: ->
            # console.log(this)
            result = ''
            result += moment(@x).format('DD MMMM YYYY') + '</br>'
            sumPoint = _.find(@points, (p) -> p.point.accountState).point
            result += "<span style='color:red'>TOTAL:</span>" + sumPoint.y + '</br>'
            for a, i in sumPoint.accountState.accounts
              balance = sumPoint.accountState.balances[i]
              result += "<span style='color: #{a.color}; margin-top: 10px; display:inline-block'>" +
                a.name + '</span>: ' + balance + ' ' + a.currency + '</br>'
              accountPoints = this.points.filter(
                (p) ->
                  p.point.transactions and p.point.transactions.find(
                    (t) -> t.account.id == a.id))
              for point in accountPoints
                for t in point.point.transactions
                  result += "<span style='width:20px; display:inline-block;'></span>" + t.description + ': ' + t.amount + '</br>'
            return result
        func: (chart) ->
          chart.redraw()
      series: series,
      size: {
       height: 400
      }
    }
  update()

  $scope.$on 'simulationRan', (__, c) ->
    update()
