if !exports
  exports = {}
_globals.draw = exports

num = _globals.num

class exports.ShapeBase

  getSnappingPoints: ->
    return [@getPosition()]

  getPosition: ->
    return new num.Num2(@shape.x, @shape.y)

  getCenter: ->
    return getPosition()

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

  markMovable: ->
    @shape.alpha = 0.6
    @shape.isPickable = true
    @shape.isMovable = true

  markRotatable: ->
    @shape.alpha = 0.6
    @shape.isPickable = true
    @shape.isRotatable = true

class exports.Circle extends exports.Shape
  _makeGraphics: ->
    super().drawCircle(0, 0, @radius)

class exports.Rectangle extends exports.Shape
  _makeGraphics: ->
    @shape.regX = @width / 2
    @shape.regY = @height / 2
    super().drawRect(0, 0, @width, @height)

  getSnappingPoints: ->
    pos = @getPosition()
    w2 = @width/2
    h2 = @height/2
    point1 = pos.add(-w2, -h2)
    point2 = pos.add(w2, -h2)
    point3 = pos.add(-h2, h2)
    point4 = pos.add(w2, h2)
    return [point1, point2, point3, point4]

  getCenter: ->
    return new num.Num2(@shape.x, @shape.y)

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
      if shape and shape.isRotatable
        @_currentRotatingShape = shape
        @_shapeStartRotation = shape.rotation


  onMouseUp: (event) ->
    @_currentMovingShape = null
    @_currentRotatingShape = null
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
    else if @_currentRotatingShape
      mouseStage =  @_stage.globalToLocal(mouse.x, mouse.y)
      centerStage = @_currentRotatingShape.wrapper.getCenter()
      # centerStage = @_currentRotatingShape.localToGlobal(centerLocal.x, centerLocal.y)
      _dragStartPosition = @_stage.globalToLocal(@_dragStartPosition.x, @_dragStartPosition.y)
      startVector = num.Num2.vectorFromPoints(centerStage, _dragStartPosition)
      currentVector = num.Num2.vectorFromPoints(centerStage, mouseStage)
      angleDiff = currentVector.angleToDeg(startVector)
      @_currentRotatingShape.rotation = @_shapeStartRotation - angleDiff
    else
      shape = @_pickShape(event.stageX, event.stageY)
      shape = null if shape and !shape.isPickable
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

