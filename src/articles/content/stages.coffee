draw = _globals.draw

class MyStage1 extends draw.MyStage
  constructor: (@id) ->
    super(@id)

    @_offsetX = 150
    @_offsetY = 70
    @zoom = 2
    @_updateTransform()

    @start = {x: 30, y: 50}

    @line1 = new draw.Line()
    @line1.stroke = 'black'
    @line1.start = @start
    @line1.end = {x: @start.x + 100, y: @start.y}
    @line2 = new draw.Line()
    @line2.stroke = 'black'
    @line2.start = @start
    @line2.end = {x: @start.x, y: @start.y + 100}

    @square = new draw.Rectangle()
    @square.setPosition({x: @start.x + 20, y: @start.y + 20})
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'

    @square.markMovable @_stage

    @addShape @square
    @addShape @line1
    @addShape @line2

    @text = new draw.Text('Put square precisely here.\n it will become green when(if) you succeed', '20px Gochi Hand')
    @_stage.addChild @text.shape

    @arrow = new draw.Arrow()
    @arrow.start = {x: 10, y: 40}
    @arrow.end = @start
    @arrow.stroke = 'black'

    @addShape @arrow


    @_stage.update()

  onLogicUpdate: ->
    position = @square.getPosition()
    if draw.epsilonEquals(position.x, @start.x, 0.2) and draw.epsilonEquals(position.y, @start.y, 0.2)
      @square.setFill('green')
    else
      @square.setFill('red')

_globals.do = ->
  new MyStage1("demo1")
