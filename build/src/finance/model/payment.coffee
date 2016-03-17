exports = window

class exports.Payment
  getTransactions: (context) ->
    throw new Error('abstract method')

  getAmount: (context) ->
    if !context
      throw new Error()
    amount = @amount
    if _.isString(amount)
      amount = eval(amount)
    return amount

  clone: ->
    c = new @constructor()
    @assignTo(c)
    return c
