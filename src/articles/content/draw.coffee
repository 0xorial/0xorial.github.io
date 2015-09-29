class MyStage
  constructor: (@id) ->
    @_stage = new createjs.Stage(@id)
    @zoom = 1

    $("#" + @id).on 'mousewheel', (event) =>
      if (event.deltaY > 0)
        @zoom *= 1.1
      else
        @zoom /= 1.1
      @_stage.setTransform(0,0, @zoom, @zoom)
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
