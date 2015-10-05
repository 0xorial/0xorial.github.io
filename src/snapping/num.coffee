if !exports
  exports = {}
_globals.num = exports

lerp = (a, b, t) ->
  return a + (b - a) * t

class exports.Num2
  constructor: (@x, @y) ->

  @vectorFromPoints: (start, end) ->
    return exports.Num2.subtract(end, start)

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
    return Math.sqrt(@distanceToSquared(x, y))

  distanceToSquared:  (x, y) ->
    if x.x != undefined
      y = x.y
      x = x.x
    if y == undefined
      y = x

    delta = this.subtract(x, y)
    return delta.x * delta.x + delta.y * delta.y

  length: ->
    return @distanceTo(0, 0)

  lerpTo: (x, y, t) ->
    if x.x != undefined
      t = y
      y = x.y
      x = x.x

    return new exports.Num2(lerp(@x, x, t), lerp(@y, y, t))

  dot: (other) ->
    return @x * other.x + @y * other.y

  cross: (other) ->
    # http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    return @x * other.y - @y * other.x

  angleTo: (other) ->
    return Math.atan2(other.y, other.x) - Math.atan2(@y, @x);

  angleToDeg: (other) ->
    return @angleTo(other) * 180 / Math.PI

  clone: ->
    return new exports.Num2(@x, @y)

  epsilonEquals: (other, epsilon = 0.01) ->
    return exports.epsilonEquals(@x, other.x, epsilon) and exports.epsilonEquals(@y, other.y, epsilon)

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

