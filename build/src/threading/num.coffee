if !exports
  exports = {}
_globals.num = exports

lerp = (a, b, t) ->
  return a + (b - a) * t

findLineCircleIntersections = (point1, point2, cx, cy, radius) ->
  dx = point2.x - point1.x;
  dy = point2.y - point1.y;

  A = dx * dx + dy * dy;
  B = 2 * (dx * (point1.x - cx) + dy * (point1.y - cy));
  C = (point1.x - cx) * (point1.x - cx) + (point1.y - cy) * (point1.y - cy) - radius * radius;

  det = B * B - 4 * A * C;
  if ((A <= 0.0000001) || (det < 0))
    return []
  else if (exports.epsilonEquals(det, 0))
    t = -B / (2 * A);
    return [new exports.Num2(point1.x + t * dx, point1.y + t * dy)]
  else
    t = ((-B + Math.sqrt(det)) / (2 * A))
    intersection1 = new exports.Num2(point1.x + t * dx, point1.y + t * dy)
    t = ((-B - Math.sqrt(det)) / (2 * A))
    intersection2 = new exports.Num2(point1.x + t * dx, point1.y + t * dy)
    return [intersection1, intersection2]

segmentContainsPoint = (point1, point2, point) ->
  dpx = (point2.x - point1.x)
  dpy = (point2.y - point1.y)
  tx = (point.x - point1.x) / dpx
  ty = (point.y - point1.y) / dpy
  if exports.epsilonEquals(dpx, 0)
    return exports.epsilonEquals(point.x, point1.x) and ty >= -0.1 and ty <= 1.1
  if exports.epsilonEquals(dpy, 0)
    return exports.epsilonEquals(point.y, point1.y) and tx >= -0.1 and tx <= 1.1
  if exports.epsilonEquals(tx, ty) and tx >= -0.1 and tx <= 1.1
    return true

  return false

exports.findLineSegmentCircleIntersections = (point1, point2, cx, cy, radius) ->
  lineIntersections = findLineCircleIntersections(point1, point2, cx, cy, radius)
  return lineIntersections.filter (i) -> segmentContainsPoint(point1, point2, i)

class exports.Num2
  constructor: (@x, @y) ->
    if @x.x != undefined
      @y = @x.y
      @x = @x.x
    else if @y == undefined
      @y = @x


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

  rotateAround: (center, angle) ->
    c = Math.cos(angle)
    s = Math.sin(angle)
    cx = center.x
    cy = center.y
    p = this
    px = p.x - cx;
    py = p.y - cy;
    xnew = px * c - py * s;
    ynew = px * s + py * c;
    return new exports.Num2(xnew + cx, ynew  + cy)

  rotateAroundDeg: (center, angleDeg) ->
    angle = angleDeg * Math.PI / 180
    return @rotateAround(center, angle)

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

