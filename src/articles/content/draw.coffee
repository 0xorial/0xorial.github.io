if !exports
  exports = {}

class exports.Num2
  constructor: (@x, @y) ->

  add: (x, y) ->
    if x.x != undefined
      y = x.y
      x = x.x

    if y == undefined
      y = x
    return new exports.Num2(@x + x, @y + y)

Victor.fromPoints = (start, end) ->
  return Victor.fromObject(end).subtract(Victor.fromObject(start));

Victor.prototype.multiplyScalar = (scalar) ->
  @x *= scalar
  @y *= scalar
  return @

exports.epsilonEquals = (x, y, epsilon = 0.01) ->
  return Math.abs(x - y) < epsilon

class exports.ShapeBase

  getSnappingPoints: ->
    return [@getPosition()]

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
    @shape.alpha = 0.6
    @shape.isPickable = true
    @shape.isMovable = true

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

class exports.MyStage
  constructor: (@id) ->
    @_stage = new createjs.Stage(@id)
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

    @_stage.on 'stagemouseup', (e) => @onMouseUp(e)
    @_stage.on 'stagemousedown', (e) => @onMouseDown(e)
    @_stage.on 'stagemousemove', (e) => @onMouseMove(e)

  onMouseDown: (event) ->
    if event.nativeEvent.which == 2
      @_lastMouseX = event.stageX
      @_lastMouseY = event.stageY

    if event.nativeEvent.which == 1
      shape = @_pickShape(event.stageX, event.stageY)
      if shape and shape.isMovable
        @_currentMovingShape = shape

  onMouseUp: (event) ->
    @_currentMovingShape = null

  onMouseMove: (event) ->
    dx = event.stageX - @_lastMouseX
    dy = event.stageY - @_lastMouseY

    if event.nativeEvent.which == 2
      @_offsetX += dx
      @_offsetY += dy
      @_updateTransform()

    if @_currentMovingShape
      @_currentMovingShape.x += dx / @zoom
      @_currentMovingShape.y += dy / @zoom
    else
      shape = @_pickShape(event.stageX, event.stageY)
      if shape != @_currentHighlightShape
        if @_currentHighlightShape
          @_currentHighlightShape.alpha = 0.6
        if shape
          shape.alpha = 1
        @_currentHighlightShape = shape

    @onLogicUpdate()
    @_stage.update()
    @_lastMouseX = event.stageX
    @_lastMouseY = event.stageY

  _pickShape: (x, y, onlyMovable = true) ->
    for i in [@_stage.children.length - 1..0] by -1
      child = @_stage.children[i]
      if !onlyMovable or child.isPickable
        point = child.globalToLocal(x,y)
        if child.hitTest(point.x, point.y)
          return child
    return null



  _updateTransform: ->
    @_stage.setTransform(@_offsetX, @_offsetY, @zoom, @zoom)
    @_stage.update()

  addShape: (shape) ->
    shape.update()
    @_stage.addChild(shape.shape)

  onLogicUpdate: ->

_globals.draw = exports