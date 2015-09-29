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
      stage.update()


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
      if (event.deltaY > 0)
        @zoom *= 1.1
      else
        @zoom /= 1.1
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


  _updateTransform: ->
    @_stage.setTransform(@_offsetX, @_offsetY, @zoom, @zoom)
    @_stage.update()


class MyStage1 extends MyStage
  constructor: (@id) ->
    super(@id)
    circle = new createjs.Shape()
    circle.graphics.beginFill("DeepSkyBlue").drawCircle(0, 0, 30)
    circle.x = 100
    circle.y = 100

    square = new createjs.Shape()
    square.graphics.beginFill("red").drawRect(0,0, 20, 30)
    injectMovable @_stage, circle
    injectMovable @_stage, square

    @_stage.addChild(circle)
    @_stage.addChild(square)

    @_stage.update()




_globals.do = ->
  new MyStage1("demo1")



class _globals.Class1
  do: ->
    alert('')
