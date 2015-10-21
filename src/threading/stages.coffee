draw = _globals.draw
num = _globals.num
scheduler = _globals.scheduler

schedule = scheduler.scheduleThreads
  threads: [
    {createTime: 0, length: 3, color: 'green'}
    {createTime: 0, length: 10, color: 'yellow'}
    {createTime: 0, length: 13, color: 'red'}
    {createTime: 0, length: 17, color: 'black'}
    {createTime: 10, length: 17, color: 'brown'}
    {createTime: 50, length: 17, color: 'blue'}
  ]
  totalCpus: 2
  maximumTime: 5


class MyStage1 extends draw.MyStage
  constructor: (@id) ->
    super(@id)

    @scale = 1

    image = new draw.Image('images/tux.svg')
    image.scale = 0.2
    image.x = 100

    @addChild image

    @drawThreads schedule

    @update()

  drawThreads: (schedule) ->
    container = new createjs.Container()
    rowHeight = 50
    timeScale = 10

    for e in schedule
      if e.type == 'assignCpu'
        rect = new draw.Rectangle(e.length*timeScale - 2, rowHeight - rowHeight * 0.4, e.thread.color)
        rect.x = e.time*timeScale
        rect.y = e.cpu.id * rowHeight
        container.addChild rect
    @addChild(container)

    container.position = new num.Num2(200, 50)


_globals.do = ->
  new MyStage1('demo1')
