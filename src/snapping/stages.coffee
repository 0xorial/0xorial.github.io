draw = _globals.draw
num = _globals.num

class Line
  constructor: (@start, @end, @movable = false) ->
    @line = new draw.Line()
    @line.stroke = 'black'
    @line.start = @start
    @line.end = @end

    if !@movable
      @shape = @line
    else
      @shape = new draw.Container()
      @shape.addShape(@line)
      @gizmo1 = new draw.Rectangle(6, 6, 'yellow')
      @gizmo1.setPosition(@start)
      @shape.addShape(@gizmo1)
      @gizmo2 = new draw.Rectangle(6, 6, 'yellow')
      @gizmo2.setPosition(@end)
      @shape.addShape(@gizmo2)

    @primitive = new LineSnappingPrimitive()
    @primitive.start = @start
    @primitive.end = @end

  onMouseDown: (globalPosition) ->
    gizmo1Position = @gizmo1.shape.globalToLocal(globalPosition.x, globalPosition.y)
    if @gizmo1.shape.hitTest(gizmo1Position.x, gizmo1Position.y)
      @movingGizmo = @gizmo1
      return true
    gizmo2Position = @gizmo2.shape.globalToLocal(globalPosition.x, globalPosition.y)
    if @gizmo2.shape.hitTest(gizmo2Position.x, gizmo2Position.y)
      @movingGizmo = @gizmo2
      return true
    return false

  onMouseMove: (stagePosition) ->
    if @movingGizmo
      if @movingGizmo == @gizmo1
        @start = stagePosition
      else
        @end = stagePosition

      @line.start = @start
      @line.end = @end
      @primitive.start = @start
      @primitive.end = @end
      @movingGizmo.setPosition(stagePosition)
      @shape.update()
      return true
    return false

  onMouseUp: ->
    @movingGizmo = null

  setSnapped: (snapped) ->
    if snapped
      @line.stroke = 'red'
    else
      @line.stroke = 'black'


class SnappingPrimitive
  getNearestPoint: (point) ->
    throw new Error('abstract')
  moveBy: (delta) ->
    throw new Error('abstract')

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

  moveBy: (delta) ->
    return new LineSnappingPrimitive(@start.add(delta), @end.add(delta))

  rotateBy: (center, angle) ->
    return new LineSnappingPrimitive(@start.rotateAround(center, angle), @end.rotateAround(center, angle))


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
    position = @square.getTopLeftCorner()
    if num.epsilonEquals(position.x, @start.x, 0.1) and num.epsilonEquals(position.y, @start.y, 0.1)
      @square.setFill('green')
    else
      @square.setFill('red')

class MyStage2 extends MyStage1
  constructor: (id) ->
    super(id)
    @snapTo = []

  snap: ->
    position = @square.getTopLeftCorner()
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
    @square0.setPosition(new num.Num2(75, 50))
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
    @square0.setPosition(new num.Num2(100, 50))
    @square0.width = 20
    @square0.height = 30
    @square0.fill = 'red'

    squarePoints = @square0.getSnappingPoints()
    @arrow1 = new draw.Arrow(squarePoints[0], line2.primitive.getNearestPoint(squarePoints[0]))
    @arrow2 = new draw.Arrow(squarePoints[2], line1.primitive.getNearestPoint(squarePoints[2]))

    @arrow3 = new draw.Arrow(squarePoints[0], squarePoints[0].subtract(24, 0), 'green')
    @arrow4 = new draw.Arrow(squarePoints[2], squarePoints[2].subtract(24, 0), 'green')

    intersection = line2.primitive.findIntersectionPoint(line1.primitive)
    @arrow5 = new draw.Arrow(squarePoints[0], intersection)
    @arrow6 = new draw.Arrow(squarePoints[2], intersection)


    @text = new draw.Text('Black arrows show how current algorithm can snap the points', '10px Gochi Hand')
    @text.setPosition(new num.Num2(90, 20))

    @text2 = new draw.Text('Green arrows show how we want to snap them.', '10px Gochi Hand')
    @text2.setPosition(new num.Num2(90, 30))


    @addShape @arrow1
    @addShape @arrow2
    @addShape @arrow3
    @addShape @arrow4
    @addShape @arrow5
    @addShape @arrow6

    @addShape line1.shape
    @addShape line2.shape
    @addShape @square0
    @addShape @text
    @addShape @text2

class MyStage7 extends draw.MyStage
  constructor: (id) ->
    super(id, true)

    line1 = new Line(new num.Num2(0,0), new num.Num2(100, 100))
    line2 = new Line(new num.Num2(100,0), new num.Num2(0, 100))

    @square0 = new draw.Rectangle()
    @square0.setPosition(new num.Num2(100, 50))
    @square0.width = 20
    @square0.height = 30
    @square0.fill = 'red'

    squarePoints = @square0.getSnappingPoints()
    @arrow1 = new draw.Arrow(squarePoints[0], line2.primitive.getNearestPoint(squarePoints[0]))
    @arrow2 = new draw.Arrow(squarePoints[2], line1.primitive.getNearestPoint(squarePoints[2]))

    @arrow3 = new draw.Arrow(squarePoints[0], squarePoints[0].subtract(24, 0), 'green')
    @arrow4 = new draw.Arrow(squarePoints[2], squarePoints[2].subtract(24, 0), 'green')

    @text = new draw.Text('Move point, together with line, to which it is snapped to another point!', '10px Gochi Hand')
    @text.setPosition(new num.Num2(90, 20))

    TweenMax.ticker.addEventListener 'tick', (e) =>
      @_stage.update()

    time = 3
    tl = new TimelineMax()

    tl.to(@arrow1.shape, time, {y: 30}, 'g')
    tl.to(@arrow3.shape, time, {y: 30}, 'g')
    tl.to(line2.shape.shape, time, {y: 30}, 'g')
    tl.delay(0.5)
    tl.repeat(-1)
    tl.repeatDelay(0.5)

    @addShape @arrow1
    @addShape @arrow2
    @addShape @arrow3
    @addShape @arrow4

    @addShape line1.shape
    @addShape line2.shape
    @addShape @square0
    @addShape @text

class SnapsDictionary
  constructor: ->
    @items = []

  getByDelta: (delta) ->
    item = _.find(@items, (item) -> item.delta.epsilonEquals(delta))
    if item
      return item
    return null

  add: (singleSnapping) ->
    existing = @getByDelta(singleSnapping.delta)
    if !existing
      existing = new MultiSnapping(singleSnapping.delta)
      @items.push existing
    existing.addSnapping(singleSnapping)

class MultiSnapping
  constructor: (@delta) ->
    @snappings = []

  addSnapping: (snapping) ->
    existing = _.find(@snappings, (s) -> s.primitive == snapping.primitive and s.point == snapping.point)
    if !existing
      @snappings.push snapping

  getValue: ->
    return @snappings.length * 10000000 / Math.max(@delta.length(), 1)


class MyStage8 extends MyStage4
  constructor: (id) ->
    super(id, true)

    line1 = new Line(new num.Num2(0,0), new num.Num2(100, 100))
    line2 = new Line(new num.Num2(100,0), new num.Num2(0, 100))
    line3 = new Line(new num.Num2(0,0), new num.Num2(100, 0))
    line4 = new Line(new num.Num2(0,0), new num.Num2(0, 100))

    @snapTo = [line1.primitive, line2.primitive, line3.primitive, line4.primitive]

    @text = new draw.Text('Now you can put it anywhere!', '11px Gochi Hand')
    @text.setPosition(new num.Num2(90, 40))

    @square = new draw.Rectangle()
    @square.setPosition(new num.Num2(0,0).add(20))
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'
    @square.markMovable @_stage

    @addShape line1.shape
    @addShape line2.shape
    @addShape line3.shape
    @addShape line4.shape
    @addShape @square
    @addShape @text


  snap: ->
    minDistance = 20
    points = @square.getSnappingPoints()
    singleSnaps = []
    for point in points
      for p in @snapTo
        nearest = p.getNearestPoint(point)
        delta = nearest.subtract(point)
        if delta.length() < minDistance
          singleSnaps.push({point: point, delta: delta, primitive: p})
    snaps = new SnapsDictionary()
    for snap in singleSnaps
      snaps.add(snap)

    for i in [0..singleSnaps.length - 1] by 1
      firstSnap = singleSnaps[i]
      for j in [i+1..singleSnaps.length - 1] by 1
        secondSnap = singleSnaps[j]

        if !firstSnap.delta.epsilonEquals(secondSnap.delta)
          pointsDelta = firstSnap.point.subtract(secondSnap.point)
          movedSecondSnap = secondSnap.primitive.moveBy(pointsDelta)
          intersection = movedSecondSnap.findIntersectionPoint(firstSnap.primitive)
          if intersection
            delta = intersection.subtract(firstSnap.point)
            snaps.add({delta: delta, point: firstSnap.point, primitive: firstSnap.primitive})
            snaps.add({delta: delta, point: secondSnap.point, primitive: secondSnap.primitive})

    nearestSnap = _.max(snaps.items, (snap) -> snap.getValue())
    if nearestSnap == Infinity or nearestSnap == -Infinity
      return num.Num2.zero
    return nearestSnap.delta

class MovementProvider
  getNearestPoint: (primitive, point) ->
    throw new Error()

  getMouseDelta: (projection, point) ->
    throw new Error()

  combineSnappings: (firstSnap, secondSnap) ->
    throw new Error()

class PanMovementProvider
  getNearestPoints: (primitive, point) ->
    return [primitive.getNearestPoint(point)]

  getMouseDelta: (projection, point) ->
    return projection.subtract(point)

  combineSnappings: (firstSnap, secondSnap) ->
    pointsDelta = firstSnap.point.subtract(secondSnap.point)
    movedSecondSnap = secondSnap.primitive.moveBy(pointsDelta)
    intersection = movedSecondSnap.findIntersectionPoint(firstSnap.primitive)
    if intersection
      return intersection.subtract(firstSnap.point)
    return null


class RotateMovementProvider
  constructor: (@center) ->

  getNearestPoints: (primitive, point) ->
    radius = @center.distanceTo(point)
    intersections = num.findLineSegmentCircleIntersections(primitive.start, primitive.end, @center.x, @center.y, radius)
    return intersections

  _getMouseDelta: (angle) ->
    snappedPosition = @mousePosition.rotateAround(@center, angle)
    return snappedPosition.subtract(@mousePosition)

  getMouseDelta: (projection, point) ->
    throw new Error() if projection.x == undefined
    v1 = num.Num2.vectorFromPoints(@center, projection)
    v2 = num.Num2.vectorFromPoints(@center, point)
    angle = v2.angleTo(v1)
    return @_getMouseDelta(angle)

  combineSnappings: (firstSnap, secondSnap) ->
    v1 = num.Num2.vectorFromPoints(@center, firstSnap.point)
    v2 = num.Num2.vectorFromPoints(@center, secondSnap.point)
    angle = v2.angleTo(v1)
    movedSecondSnap = secondSnap.primitive.rotateBy(@center, angle)
    intersection = movedSecondSnap.findIntersectionPoint(firstSnap.primitive)
    if intersection and intersection.epsilonEquals(firstSnap.point)
      return @getMouseDelta(intersection, firstSnap.point)
    return null

class MyStage9 extends draw.MyStage
  constructor: (id) ->
    super(id, true)

    start = new num.Num2(85, 32)
    line1 = new draw.Line(start, start.add(100, 0))
    line2 = new draw.Line(start, start.add(0, 100))

    @square0 = new draw.Rectangle(70, 70, 'red')
    @square0.setPosition(new num.Num2(100, 50))

    squarePoints = @square0.getSnappingPoints()
    # @arrow1 = new draw.Arrow(squarePoints[0], line2.primitive.getNearestPoint(squarePoints[0]))
    # @arrow2 = new draw.Arrow(squarePoints[2], line1.primitive.getNearestPoint(squarePoints[2]))

    # @arrow3 = new draw.Arrow(squarePoints[0], squarePoints[0].subtract(24, 0), 'green')
    # @arrow4 = new draw.Arrow(squarePoints[2], squarePoints[2].subtract(24, 0), 'green')

    @text = new draw.Text('Move point, together with line, to which it is snapped to another point!', '10px Gochi Hand')
    @text.setPosition(new num.Num2(90, 20))

    # TweenMax.ticker.addEventListener 'tick', (e) =>
    #   @_stage.update()

    # time = 3
    # tl = new TimelineMax()

    # tl.to(@arrow1.shape, time, {y: 30}, 'g')
    # tl.to(@arrow3.shape, time, {y: 30}, 'g')
    # tl.to(line2.shape.shape, time, {y: 30}, 'g')
    # tl.delay(0.5)
    # tl.repeat(-1)
    # tl.repeatDelay(0.5)

    # @addShape @arrow1
    # @addShape @arrow2
    # @addShape @arrow3
    # @addShape @arrow4

    @addShape line1
    @addShape line2
    @addShape @square0
    @addShape @text

class MyStage10 extends draw.MyStage
  constructor: (@id) ->
    super(@id, true)

    @zoom = 2
    @_updateTransform()

    @lines = []
    @snapTo = []

    @start = new num.Num2(30, 50)
    startLine = @start.add -0.5

    line1 = new Line(new num.Num2(0,0), new num.Num2(100, 0), true)
    line2 = new Line(new num.Num2(0,0), new num.Num2(0, 100), true)

    @square = new draw.Rectangle()
    @square.setPosition(num.Num2.zero.add(10, 15))
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'
    @square.markRotatable()
    @square.movementProvider = new RotateMovementProvider(@square.getCenter())

    @square0 = new draw.Rectangle()
    @square0.setPosition(@start.add(40))
    @square0.width = 20
    @square0.height = 30
    @square0.fill = 'red'
    @square0.markMovable()
    @square0.movementProvider = new PanMovementProvider()

    @addShape @square
    @addShape @square0

    @addSnapLine(line1)
    @addSnapLine(line2)

    @_stage.update()

  addSnapLine: (line) ->
    @addShape line.shape
    @snapTo.push line.primitive
    @lines.push line

  onMouseDown: (e) ->
    handled = false
    if e.nativeEvent.which == 1
      stagePosition = new num.Num2(e.rawX, e.rawY)
      for s in @lines
        if s.onMouseDown(stagePosition)
          handled = true
          break
    if !handled
      super(e)

  onMouseMove: (e) ->
    handled = false
    stagePosition = new num.Num2(@_stage.globalToLocal(e.rawX, e.rawY))
    for s in @lines
      if s.onMouseMove(stagePosition)
        handled = true
        break
    if !handled
      super(e)
    else
      @_stage.update()

  onMouseUp: (e) ->
    for s in @lines
      s.onMouseUp()
    super(e)

  snap: ->
    minDistance = 20
    points = @getSnappingShape().wrapper.getSnappingPoints()
    movementProvider = @getSnappingShape().wrapper.movementProvider
    movementProvider.mousePosition = @mousePosition
    singleSnaps = []
    for point in points
      for p in @snapTo
        nearest = movementProvider.getNearestPoints(p, point)
        for n in nearest
          delta = movementProvider.getMouseDelta(n, point)
          if delta.length() < minDistance
            singleSnaps.push({point: point, delta: delta, primitive: p})
    snaps = new SnapsDictionary()
    for snap in singleSnaps
      snaps.add(snap)

    for i in [0..singleSnaps.length - 1] by 1
      firstSnap = singleSnaps[i]
      for j in [i+1..singleSnaps.length - 1] by 1
        secondSnap = singleSnaps[j]

        if !firstSnap.delta.epsilonEquals(secondSnap.delta)
          intersectionDelta = movementProvider.combineSnappings(firstSnap, secondSnap)
          if intersectionDelta
            delta = intersectionDelta
            snaps.add({delta: delta, point: firstSnap.point, primitive: firstSnap.primitive})
            snaps.add({delta: delta, point: secondSnap.point, primitive: secondSnap.primitive})

    nearestSnap = _.max(snaps.items, (snap) -> snap.getValue())
    if nearestSnap == Infinity or nearestSnap == -Infinity
      return num.Num2.zero
    return nearestSnap.delta



_globals.do = ->
  new MyStage1('demo1')
  new MyStage2('demo2')
  new MyStage3('demo3')
  new MyStage4('demo4')
  new MyStage5('demo5')
  new MyStage6('demo6')
  new MyStage7('demo7')
  new MyStage8('demo8')
  new MyStage9('demo9')
  new MyStage10('demo10')
