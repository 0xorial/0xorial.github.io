draw = _globals.draw
num = _globals.num


class MyStage1 extends draw.MyStage
  constructor: (@id) ->
    super(@id)


    image = new draw.Image('images/tux.svg')
    image.scale = 0.2

    rect = new draw.Rectangle(20, 40)

    @addChild image
    @addChild rect

    @update()

_globals.do = ->
  new MyStage1('demo1')
