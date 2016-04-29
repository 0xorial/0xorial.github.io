exports = window;

class exports.Account
  constructor: (@currency, @name, @color, @id) ->

  toJson: () ->
    return {
      currency: @currency
      name: @name
      color: @color
    }
  @fromJson: (json) ->
    r = new exports.Account(json.currency, json.name, json.color)
    return r
