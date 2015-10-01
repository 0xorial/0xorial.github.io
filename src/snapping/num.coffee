if !exports
  exports = {}
_globals.num = exports

class exports.Num2
  constructor: (@x, @y) ->

  toString: ->
    return 'x ' + @x + '; y:' + @y

  add: (x, y) ->
    if x.x != undefined
      y = x.y
      x = x.x

    if y == undefined
      y = x
    return new exports.Num2(@x + x, @y + y)

  addThis: (x,y) ->
    if x.x != undefined
      y = x.y
      x = x.x

    if y == undefined
      y = x

    @x += x
    @y += y

  multiply: (x) ->
    return new exports.Num2(@x * x, @y * x)

  subtract: (x, y) ->
    if x.x != undefined
      y = x.y
      x = x.x

    if y == undefined
      y = x
    return new exports.Num2(@x - x, @y - y)

  distanceTo: (x, y) ->
    if x.x != undefined
      y = x.y
      x = x.x
    if y == undefined
      y = x

    delta = this.subtract(x, y)
    return Math.sqrt(delta.x * delta.x + delta.y * delta.y)

  clone: ->
    return new exports.Num2(@x, @y)

  @subtract: (num1, num2) ->
    return new exports.Num2(num1.x - num2.x, num1.y - num2.y)

exports.Num2.zero = new exports.Num2(0,0)

Victor.fromPoints = (start, end) ->
  return Victor.fromObject(end).subtract(Victor.fromObject(start));

Victor.prototype.multiplyScalar = (scalar) ->
  @x *= scalar
  @y *= scalar
  return @

exports.epsilonEquals = (x, y, epsilon = 0.01) ->
  return Math.abs(x - y) < epsilon

