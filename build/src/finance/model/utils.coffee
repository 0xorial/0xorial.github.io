exports = window

exports.sortTransactions = (transactions) ->
  transactions.sort (a,b) ->
    if a.date.isSame(b.date)
      if a.id == b.id
        return 0
      if a.id < b.id
        return -1
      return 1
    if a.date.isBefore(b.date)
      return -1
    return 1
