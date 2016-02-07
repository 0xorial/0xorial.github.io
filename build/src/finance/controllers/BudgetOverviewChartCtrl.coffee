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
        t = dateTransactions[0]
        balance = t.accountState.getAccountBalance(t.account)
        data.push({
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
      sum = _.sum(lastTransaction.accountState.balances)
      sumData.push({
        x: lastTransaction.date.valueOf()
        y: sum
        amount: sum
        description: 'sum'
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
          # headerFormat: '{series.description}<br>{series.date}'
          pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change}%)<br/>',
          valueDecimals: 2
      series: series,
      # size: {
      #  width: 600,
      #  height: 500
      # }
    }
  update()

  $scope.$on 'simulationRan', (__, c) ->
    update()
