exports = window

class exports.AccountsState
  constructor: (@accounts, @balances) ->
    if !@balances
      @balances = @accounts.map -> 0

  execute: (account, amount) ->
    newBalances = []
    found = false
    for b, index in @balances
      a = @accounts[index]
      if not found and a == account
        found = true
        newBalances.push(b + amount)
      else
        newBalances.push(b)
    return new exports.AccountsState(@accounts, newBalances)

  getAccountBalance: (account) ->
    index = _.indexOf(@accounts, account)
    if index == -1
      throw new Error('account not found')
    return @balances[index]
