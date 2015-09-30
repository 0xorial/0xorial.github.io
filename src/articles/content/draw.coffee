if !exports
  exports = {}

Victor.fromPoints = (start, end) ->
  return Victor.fromObject(end).subtract(Victor.fromObject(start));

Victor.prototype.multiplyScalar = (scalar) ->
  @x *= scalar
  @y *= scalar
  return @

exports.epsilonEquals = (x, y, epsilon = 0.01) ->
  return Math.abs(x - y) < epsilon

class exports.ShapeBase
  getPosition: ->
    return {x: @shape.x, y: @shape.y}

  setPosition: (x, y) ->
    if x.x
      y = x.y
      x = x.x
    @shape.x = x
    @shape.y = y
    @update()


class exports.Shape extends exports.ShapeBase
  constructor: ->
    @shape = new createjs.Shape()

  _makeGraphics: () ->
    g = @shape.graphics
    if @stroke
      g.beginStroke @stroke
    if @fill
      g.beginFill @fill
    return g

  setFill: (fill) ->
    @fill = fill
    @update()

  setStroke: (stroke) ->
    @stroke = stroke
    @update()

  update: ->
    @shape.graphics.clear()
    @_makeGraphics()

  markMovable: (stage) ->
    exports.injectMovable stage, @shape

class exports.Circle extends exports.Shape
  _makeGraphics: ->
    super().drawCircle(0, 0, @radius)

class exports.Rectangle extends exports.Shape
  _makeGraphics: ->
    super().drawRect(0, 0, @width, @height)

class exports.Line extends exports.Shape
  _makeGraphics: ->
    super().moveTo(@start.x, @start.y).lineTo(@end.x, @end.y)

class exports.Arrow extends exports.Shape
  _makeGraphics: ->
    direction = Victor.fromPoints(@start, @end).normalize()
    angle = 150
    length = 10
    leftArrow = direction.clone().rotateDeg(-angle).multiplyScalar(length).add(@end)
    rightArrow = direction.clone().rotateDeg(angle).multiplyScalar(length).add(@end)

    super().moveTo(@start.x, @start.y)
      .lineTo(@end.x, @end.y)
      .lineTo(leftArrow.x, leftArrow.y)
      .lineTo(rightArrow.x, rightArrow.y)
      .lineTo(@end.x, @end.y)

class exports.Text extends exports.ShapeBase
  constructor: (text, font) ->
    @shape = new createjs.Text(text, font)

  setText: (text) ->
    @shape.text = text

  setFont: (font) ->
    @shape.font = font

  update: ->


exports.injectMovable = (stage, shape) ->

  shape.alpha = 0.5

  lastPosition = {x: 0, y: 0}
  shape.addEventListener 'mousedown', (event) ->
    if event.nativeEvent.which == 1
      lastPosition = stage.globalToLocal(event.stageX, event.stageY)

  shape.addEventListener 'pressmove', (event) ->
    if event.nativeEvent.which == 1
      stagePoint = stage.globalToLocal(event.stageX, event.stageY)
      dx = stagePoint.x - lastPosition.x
      dy = stagePoint.y - lastPosition.y
      shape.x += dx
      shape.y += dy
      lastPosition = stagePoint
      # stage.update()


  shape.addEventListener 'mouseover', (event) ->
    shape.alpha = 1
    stage.update()

  shape.addEventListener 'mouseout', (event) ->
    shape.alpha = 0.5
    stage.update()


class exports.MyStage
  constructor: (@id) ->
    @_stage = new createjs.Stage(@id)
    @_stage.enableMouseOver(60)
    @zoom = 1

    $("#" + @id).on 'mousewheel', (event) =>
      event.preventDefault()
      oldZoom = @zoom
      if (event.deltaY > 0)
        @zoom *= 1.1
      else
        @zoom /= 1.1

      pointX = @_stage.mouseX
      pointY = @_stage.mouseY
      zoom = @zoom/oldZoom
      @_offsetX = @_offsetX * zoom - pointX * zoom + pointX
      @_offsetY = @_offsetY * zoom - pointY * zoom + pointY

      @_updateTransform()

    @_lastMouseX = 0
    @_lastMouseY = 0

    @_offsetX = 0
    @_offsetY = 0

    @_stage.on 'stagemousedown', (event) =>
      if event.nativeEvent.which == 2
        @_lastMouseX = event.stageX
        @_lastMouseY = event.stageY

      # if event.nativeEvent.which == 1
      #   shape = @_pickShape(event.stageX, event.stageY)

    @_stage.on 'stagemousemove', (event) =>
      if event.nativeEvent.which == 2
        dx = event.stageX - @_lastMouseX
        dy = event.stageY - @_lastMouseY

        @_offsetX += dx
        @_offsetY += dy

        @_lastMouseX = event.stageX
        @_lastMouseY = event.stageY
        @_updateTransform()

      @onLogicUpdate()
      @_stage.update()

    update = =>
      @onLogicUpdate()
      @_stage.update()

    # setInterval(update, 100)


  _updateTransform: ->
    @_stage.setTransform(@_offsetX, @_offsetY, @zoom, @zoom)
    @_stage.update()

  addShape: (shape) ->
    shape.update()
    @_stage.addChild(shape.shape)

  onLogicUpdate: ->

_globals.draw = exports