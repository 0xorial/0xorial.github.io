class MyStage
  constructor: (@id) ->
    @_stage = new createjs.Stage(@id)
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
    circle.graphics.beginFill("DeepSkyBlue").drawCircle(0, 0, 10)
    circle.x = 100
    circle.y = 100
    @_stage.addChild(circle)
    @_stage.update()




_globals.do = ->
  new MyStage1("demo1")



class _globals.Class1
  do: ->
    alert('')
