exports = window

class exports.SimulationContext
  constructor: (@accounts) ->
    @nextTransactionId = 0
    @transactions = []
    @currentAccountsState = new exports.AccountsState(@accounts)

  transaction: (date, amount, account, description, payment) ->
    t = new exports.Transaction(date, amount, account, description, payment, @nextTransactionId++)
    @transactions.push t
    return t

  executeTransactions:  ->
    exports.sortTransactions @transactions

    for t in @transactions
      newState = @currentAccountsState.execute(t.account, t.amount)
      t.accountState = newState
      @currentAccountsState = newState
