if !exports
  exports = {}
_globals.draw = exports

num = _globals.num

class exports.ShapeBase

  getSnappingPoints: ->
    return [@getPosition()]

  getPosition: ->
    return new num.Num2(@shape.x, @shape.y)

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
    @shape.wrapper = this

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

  getSnappingPoints: ->
    point1 = @getPosition()
    point2 = point1.add(@width, 0)
    point3 = point1.add(0, @height)
    point4 = point1.add(@width, @height)
    return [point1, point2, point3, point4]

class exports.Line extends exports.Shape
  _makeGraphics: ->
    super().moveTo(@start.x, @start.y).lineTo(@end.x, @end.y)

class exports.Arrow extends exports.Shape
  constructor: (@start, @end, stroke) ->
    super()
    @stroke = 'black'
    @stroke = stroke if stroke

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

    @_offset = new num.Num2(80, 50)
    @zoom = 2
    @_updateTransform()

    setInterval((() => @_stage.update()), 300)

    $("#" + @id).on 'mousewheel', (event) =>
      event.preventDefault()
      oldZoom = @zoom
      if (event.deltaY > 0)
        @zoom *= 1.1
      else
        @zoom /= 1.1

      point = new num.Num2(@_stage.mouseX, @_stage.mouseY)
      zoom = @zoom/oldZoom
      @_offset = @_offset.multiply(zoom).subtract(point.multiply(zoom)).add(point)

      @_updateTransform()

    @_offset = new num.Num2(0, 0)

    @_stage.on 'stagemouseup', (e) => @onMouseUp(e)
    @_stage.on 'stagemousedown', (e) => @onMouseDown(e)
    @_stage.on 'stagemousemove', (e) => @onMouseMove(e)

  onMouseDown: (event) ->
    @_dragStartPosition = {x: event.stageX, y: event.stageY}
    @_dragStartOffset = @_offset.clone()

    if event.nativeEvent.which == 1
      shape = @_pickShape(event.stageX, event.stageY)
      if shape and shape.isMovable
        @_currentMovingShape = shape
        @_shapeStartPosition = new num.Num2(shape.x, shape.y)


  onMouseUp: (event) ->
    @_currentMovingShape = null
    @_dragStartPosition = null
    @_dragStartOffset = null

  onMouseMove: (event) ->
    mouse = new num.Num2(event.stageX, event.stageY)
    if @_dragStartPosition
      delta = num.Num2.subtract(mouse, @_dragStartPosition)

    if event.nativeEvent.which == 2
      @_offset = @_dragStartOffset.add(delta)
      @_updateTransform()

    if @_currentMovingShape
      zoomedDelta = delta.multiply(1/@zoom)
      newPosition = @_shapeStartPosition.add(zoomedDelta)
      console.log 'position' + newPosition.toString()
      @_currentMovingShape.x = newPosition.x
      @_currentMovingShape.y = newPosition.y

      snappingDelta = @snap()

      console.log 'snapping delta' + snappingDelta.toString()

      newPosition.addThis(snappingDelta)
      console.log 'new position' + newPosition.toString()
      @_currentMovingShape.x = newPosition.x
      @_currentMovingShape.y = newPosition.y

    else
      shape = @_pickShape(event.stageX, event.stageY)
      shape = null if !shape.isPickable
      if shape != @_currentHighlightShape
        if @_currentHighlightShape
          @_currentHighlightShape.alpha = 0.6
        if shape
          shape.alpha = 1
        @_currentHighlightShape = shape

    @onLogicUpdate()
    @_stage.update()

  snap: () ->
    return num.Num2.zero

  _pickShape: (x, y, onlyMovable = true) ->
    for i in [@_stage.children.length - 1..0] by -1
      child = @_stage.children[i]
      if !onlyMovable or child.isPickable
        point = child.globalToLocal(x,y)
        if child.hitTest(point.x, point.y)
          return child
    return null



  _updateTransform: ->
    @_stage.setTransform(@_offset.x, @_offset.y, @zoom, @zoom)
    @_stage.update()

  addShape: (shape) ->
    shape.update()
    @_stage.addChild(shape.shape)

  onLogicUpdate: ->

