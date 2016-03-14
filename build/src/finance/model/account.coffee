exports = window;

class exports.Account
  constructor: (@currency, @name, @color, @id) ->

  toJson: (context) ->
    if !@id
      throw new Error()
    return {
      id: context.registerObjectWithId(@, @id)
      currency: @currency
      name: @name
      color: @color
    }
  @fromJson: (json, context) ->
    r = new exports.Account(json.currency, json.name, json.color)
    context.registerObjectWithId(json.id, r)
    return r
