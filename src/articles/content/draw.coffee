Victor.fromPoints = (start, end) ->
  return Victor.fromObject(end).subtract(Victor.fromObject(start));

Victor.prototype.multiplyScalar = (scalar) ->
  @x *= scalar
  @y *= scalar
  return @

epsilonEquals = (x, y, epsilon = 0.01) ->
  return Math.abs(x - y) < epsilon

class ShapeBase
  getPosition: ->
    return {x: @shape.x, y: @shape.y}

  setPosition: (x, y) ->
    if x.x
      y = x.y
      x = x.x
    @shape.x = x
    @shape.y = y
    @update()


class Shape extends ShapeBase
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
    injectMovable stage, @shape

class Circle extends Shape
  _makeGraphics: ->
    super().drawCircle(0, 0, @radius)

class Rectangle extends Shape
  _makeGraphics: ->
    super().drawRect(0, 0, @width, @height)

class Line extends Shape
  _makeGraphics: ->
    super().moveTo(@start.x, @start.y).lineTo(@end.x, @end.y)

class Arrow extends Shape
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

class Text extends ShapeBase
  constructor: (text, font) ->
    @shape = new createjs.Text(text, font)

  setText: (text) ->
    @shape.text = text

  setFont: (font) ->
    @shape.font = font

  update: ->


injectMovable = (stage, shape) ->

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


class MyStage
  constructor: (@id) ->
    @_stage = new createjs.Stage(@id)
    @_stage.enableMouseOver(60)
    @zoom = 1

    $("#" + @id).on 'mousewheel', (event) =>
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


class MyStage1 extends MyStage
  constructor: (@id) ->
    super(@id)

    @start = {x: 30, y: 50}

    @line1 = new Line()
    @line1.stroke = 'black'
    @line1.start = @start
    @line1.end = {x: @start.x + 100, y: @start.y}
    @line2 = new Line()
    @line2.stroke = 'black'
    @line2.start = @start
    @line2.end = {x: @start.x, y: @start.y + 100}

    @square = new Rectangle()
    @square.setPosition({x: @start.x + 20, y: @start.y + 20})
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'

    @square.markMovable @_stage

    @addShape @square
    @addShape @line1
    @addShape @line2

    @text = new Text('Put square precisely here.\n it will become green when(if) you succeed', '20px Gochi Hand')
    @_stage.addChild @text.shape

    @arrow = new Arrow()
    @arrow.start = {x: 10, y: 40}
    @arrow.end = @start
    @arrow.stroke = 'black'

    @addShape @arrow


    @_stage.update()

  onLogicUpdate: ->
    position = @square.getPosition()
    if epsilonEquals(position.x, @start.x, 1) and epsilonEquals(position.y, @start.y, 1)
      @square.setFill('green')
    else
      @square.setFill('red')




_globals.do = ->
  new MyStage1("demo1")



class _globals.Class1
  do: ->
    alert('')
