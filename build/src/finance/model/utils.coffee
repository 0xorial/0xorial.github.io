exports = window

exports.sortByDateAndId = (items, dateSelector) ->
  items.sort (a,b) ->
    aDate = dateSelector(a)
    bDate = dateSelector(b)
    if aDate.isSame(bDate)
      if a.id == b.id
        return 0
      if a.id < b.id
        return -1
      return 1
    if aDate.isBefore(bDate)
      return -1
    return 1

exports.sortTransactions = (transactions) ->
  exports.sortByDateAndId(transactions, (t) -> t.date)
