exports = window

class exports.Payment
  getTransactions: (context) ->
    throw new Error('abstract method')

  getAmount: (evaluator) ->
    if !evaluator.evaluateAmount
      throw new Error()
    return evaluator.evaluateAmount(@amount)

  clone: ->
    c = new @constructor()
    @assignTo(c)
    return c
