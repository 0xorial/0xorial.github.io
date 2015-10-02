draw = _globals.draw
num = _globals.num

class Line
  constructor: (@start, @end) ->
    @shape = new draw.Line()
    @shape.stroke = 'black'
    @shape.start = @start
    @shape.end = @end
    @primitive = new LineSnappingPrimitive()
    @primitive.start = @start
    @primitive.end = @end


class SnappingPrimitive
  getNearestPoint: (point) ->

class LineSnappingPrimitive
  constructor: (@start, @end) ->

  getNearestPoint: (point) ->
    l2 = @end.distanceToSquared(@start)
    if l2 < 0.01
      return @start.lerpTo(@end)
    t = point.subtract(@start).dot(@end.subtract(@start)) / l2
    return @start if t < 0
    return @end if t > 1
    return @start.lerpTo(@end, t)

  findIntersectionPoint: (p2) ->
    # http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
    p = @start
    q = p2.start
    r = @end.subtract @start
    s = p2.end.subtract p2.start

    t = q.subtract(p).cross(s) / r.cross(s)

    return null if t < 0 or t > 1
    return @start.lerpTo(@end, t)


class MyStage1 extends draw.MyStage
  constructor: (@id) ->
    super(@id)

    @zoom = 2
    @_updateTransform()

    @start = new num.Num2(30, 50)
    startLine = @start.add -0.5

    @line1 = new draw.Line()
    @line1.stroke = 'black'
    @line1.start = startLine
    @line1.end = startLine.add(100, 0)
    @line2 = new draw.Line()
    @line2.stroke = 'black'
    @line2.start = startLine
    @line2.end = startLine.add(0, 100)

    @square = new draw.Rectangle()
    @square.setPosition(@start.add(20))
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'

    @square.markMovable @_stage

    @addShape @line1
    @addShape @line2
    @addShape @square

    @text = new draw.Text('Put square precisely in the corner.\n it will become green when(if) you succeed', '20px Gochi Hand')
    @_stage.addChild @text.shape

    @arrow = new draw.Arrow({x: 10, y: 40}, @start)
    @arrow.stroke = 'black'

    @addShape @arrow
    @_stage.update()

  onLogicUpdate: ->
    position = @square.getPosition()
    if num.epsilonEquals(position.x, @start.x, 0.1) and num.epsilonEquals(position.y, @start.y, 0.1)
      @square.setFill('green')
    else
      @square.setFill('red')

class MyStage2 extends MyStage1
  constructor: (id) ->
    super(id)
    @snapTo = []

  snap: ->
    position = @square.getPosition()
    if position.distanceTo(@start) < 10
        return @start.subtract(position)

    return num.Num2.zero

class MyStage3 extends MyStage1
  constructor: (id) ->
    super(id)
    p = new LineSnappingPrimitive()
    p.start = @start
    p.end = @start.add(100, 0)

    p1 = new LineSnappingPrimitive()
    p1.start = @start
    p1.end = @start.add(0, 100)

    @snapTo = [p, p1]

  snap: ->
    minDistance = 10
    points = @square.getSnappingPoints()
    snaps = []
    for point in points
      for p in @snapTo
        nearest = p.getNearestPoint(point)
        distance = nearest.distanceTo point
        if distance < minDistance
          snaps.push({nearest: nearest, point: point, distance: distance})

    nearestSnap = _.min(snaps, (snap) -> snap.distance)
    if nearestSnap == Infinity
      return num.Num2.zero
    return nearestSnap.nearest.subtract(nearestSnap.point)

class MyStage4 extends draw.MyStage
  constructor: (id, suppressShapes = false) ->
    super(id)

    if !suppressShapes

      line1 = new Line(new num.Num2(0,0), new num.Num2(100, 0))
      line2 = new Line(new num.Num2(0,0), new num.Num2(0, 100))

      @snapTo = [line1.primitive, line2.primitive]

      pt = line1.primitive.findIntersectionPoint(line2.primitive)

      @square = new draw.Rectangle()
      @square.setPosition(new num.Num2(0,0).add(20))
      @square.width = 20
      @square.height = 30
      @square.fill = 'red'
      @square.markMovable @_stage

      @addShape line1.shape
      @addShape line2.shape
      @addShape @square


  snap: ->
    minDistance = 10
    points = @square.getSnappingPoints()
    snaps = []
    for point in points
      for p in @snapTo
        nearest = p.getNearestPoint(point)
        distance = nearest.distanceTo point
        if distance < minDistance
          snaps.push({nearest: nearest, point: point, distance: distance, weight: 1})
    intersections = []
    for i in [0..@snapTo.length - 1] by 1
      for j in [i+1..@snapTo.length - 1] by 1
        intersection = @snapTo[i].findIntersectionPoint(@snapTo[j])
        intersections.push(intersection) if intersection

    for point in points
      for p in intersections
        nearest = p
        distance = nearest.distanceTo point
        if distance < minDistance
          snaps.push({nearest: nearest, point: point, distance: distance, weight: 100})

    nearestSnap = _.min(snaps, (snap) -> Math.max(snap.distance, 5) / snap.weight)
    if nearestSnap == Infinity or nearestSnap == -Infinity
      return num.Num2.zero
    return nearestSnap.nearest.subtract(nearestSnap.point)

class MyStage5 extends MyStage4
  constructor: (id) ->
    super(id, true)

    line1 = new Line(new num.Num2(0,0), new num.Num2(100, 100))
    line2 = new Line(new num.Num2(100,0), new num.Num2(0, 100))

    @snapTo = [line1.primitive, line2.primitive]

    @square0 = new draw.Rectangle()
    @square0.setPosition(new num.Num2(65, 35))
    @square0.width = 20
    @square0.height = 30
    @square0.fill = 'green'
    @square0.shape.alpha = 0.3

    @text = new draw.Text('Ideally you would like to put it as green square shows...', '11px Gochi Hand')
    @text.setPosition(new num.Num2(90, 40))

    @square = new draw.Rectangle()
    @square.setPosition(new num.Num2(0,0).add(20))
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'
    @square.markMovable @_stage

    @addShape line1.shape
    @addShape line2.shape
    @addShape @square0
    @addShape @square
    @addShape @text

class MyStage6 extends draw.MyStage
  constructor: (id) ->
    super(id, true)

    line1 = new Line(new num.Num2(0,0), new num.Num2(100, 100))
    line2 = new Line(new num.Num2(100,0), new num.Num2(0, 100))

    @square0 = new draw.Rectangle()
    @square0.setPosition(new num.Num2(90, 35))
    @square0.width = 20
    @square0.height = 30
    @square0.fill = 'red'

    squarePoints = @square0.getSnappingPoints()
    @arrow1 = new draw.Arrow(squarePoints[0], line2.primitive.getNearestPoint(squarePoints[0]))
    @arrow2 = new draw.Arrow(squarePoints[2], line1.primitive.getNearestPoint(squarePoints[2]))

    @arrow3 = new draw.Arrow(squarePoints[0], squarePoints[0].subtract(24, 0), 'green')
    @arrow4 = new draw.Arrow(squarePoints[2], squarePoints[2].subtract(24, 0), 'green')

    @text = new draw.Text('Black arrows show how current algorithm can snap the points', '10px Gochi Hand')
    @text.setPosition(new num.Num2(90, 20))

    @text2 = new draw.Text('Green arrows show how we want to snap them.', '10px Gochi Hand')
    @text2.setPosition(new num.Num2(90, 30))


    @addShape @arrow1
    @addShape @arrow2
    @addShape @arrow3
    @addShape @arrow4

    @addShape line1.shape
    @addShape line2.shape
    @addShape @square0
    @addShape @text
    @addShape @text2


_globals.do = ->
  new MyStage1('demo1')
  new MyStage2('demo2')
  new MyStage3('demo3')
  new MyStage4('demo4')
  new MyStage5('demo5')
  new MyStage6('demo6')
