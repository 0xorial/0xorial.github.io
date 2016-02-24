app.controller 'BudgetOverviewChartCtrl', ($scope, SimulationService, DataService) ->

  $scope.$watch 'accounts', ( -> update()), true

  update = ->
    $scope.accounts = DataService.getAccounts().map (a) ->

      setProperties = (proxy, account) ->
        proxy.id = account.id
        proxy.name = account.name
        proxy.color = account.color
        proxy.account = account

      existingAccount = _.find $scope.accounts, (t) ->
        t.id == a.id
      if !existingAccount
        existingAccount = {isSelected: true}
      setProperties(existingAccount, a)
      return existingAccount

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
          transaction: t,
          description: t.description,
          amount: t.amount
          x: t.date.valueOf(),
          y: balance})

      series.push({
        color: tinycolor(account.color).toHexString()
        name: account.name
        data: data
        marker:
            enabled: true
            radius: 4
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
      marker:
          enabled: true
          radius: 4
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
        tooltip:
          useHTML: true
          formatter: ->
            console.log(this)
            result = ''
            result += moment(@x).format('DD MMMM YYYY') + '</br>'
            sumPoint = _.find(@points, (p) -> p.point.accountState).point
            result += "<span style='color:red'>TOTAL:</span>" + sumPoint.y + '</br>'
            for a, i in sumPoint.accountState.accounts
              balance = sumPoint.accountState.balances[i]
              result += "<span style='color: #{a.color}; margin-top: 10px; display:inline-block'>" + a.name + '</span>: ' + balance + ' ' + a.currency + '</br>'
              accountPoints = this.points.filter((p) -> p.point.transaction and p.point.transaction.account.id == a.id)
              for point in accountPoints
                result += "<span style='width:20px; display:inline-block;'></span>" + point.point.transaction.description + ': ' + point.point.transaction.amount + '</br>'
            return result
      series: series,
      # size: {
      #  width: 600,
      #  height: 500
      # }
    }
  update()

  $scope.$on 'simulationRan', (__, c) ->
    update()
