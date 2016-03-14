exports = window

class exports.Payment
  getTransactions: (context) ->
    throw new Error('abstract method')

  clone: ->
    c = new @constructor()
    @assignTo(c)
    return c
