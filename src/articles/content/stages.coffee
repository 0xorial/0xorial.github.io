draw = _globals.draw
num = _globals.num

class MyStage1 extends draw.MyStage
  constructor: (@id) ->
    super(@id)

    @_offsetX = 150
    @_offsetY = 70
    @zoom = 2
    @_updateTransform()

    @start = new num.Num2(30, 50)
    startLine = @start.add -0.5

    @line1 = new draw.Line()
    @line1.stroke = 'black'
    @line1.start = startLine
    @line1.end = startLine.add(100, 0)
    @line2 = new draw.Line()
    @line2.stroke = 'black'
    @line2.start = startLine
    @line2.end = startLine.add(0, 100)

    @square = new draw.Rectangle()
    @square.setPosition(@start.add(20))
    @square.width = 20
    @square.height = 30
    @square.fill = 'red'

    @square.markMovable @_stage

    @addShape @line1
    @addShape @line2
    @addShape @square

    @text = new draw.Text('Put square precisely in the corner.\n it will become green when(if) you succeed', '20px Gochi Hand')
    @_stage.addChild @text.shape

    @arrow = new draw.Arrow()
    @arrow.start = {x: 10, y: 40}
    @arrow.end = @start
    @arrow.stroke = 'black'

    @addShape @arrow
    @_stage.update()

  onLogicUpdate: ->
    position = @square.getPosition()
    if num.epsilonEquals(position.x, @start.x, 0.1) and num.epsilonEquals(position.y, @start.y, 0.1)
      @square.setFill('green')
    else
      @square.setFill('red')

class MyStage2 extends MyStage1
  constructor: ->
    super('demo2')

  snap: ->
    position = @square.getPosition()
    if position.distanceTo(@start) < 10
        return @start.subtract(position)

    return num.Num2.zero


_globals.do = ->
  new MyStage1('demo1')
  new MyStage2('demo2')