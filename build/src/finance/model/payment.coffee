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

  @property('id', {
    get: ->
      if @_id == undefined
        @_id = -1
      return @_id
    set: (v) ->
      if @id != -1 
        throw new Error()
      @_id = v
    })
