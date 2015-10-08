draw = _globals.draw
num = _globals.num

insertEvent = (array, event) ->
  insertAt = 0
  for e in array
    if e.time > event.time
      break
    insertAt++
  array.splice(insertAt, 0, event)

class CpuSet
  constructor: (count) ->
    @cpus = []
    for i in [0..count-1] by 1
      @cpus.push {id: i}

  freeCpusCount: ->
    return @cpus.length

  takeCpu: ->
    cpu = @cpus.splice(0, 1)[0]
    return cpu

  putCpu: (cpu) ->
    @cpus.push cpu

  any: ->
    return @freeCpusCount() > 0

class Thread
  constructor: (@id, @params) ->
    @totalTime = @params.length
    @leftTime = @totalTime

  run: (time) ->
    if @leftTime <= time
      took = @leftTime
      @leftTime = 0
      return took
    else
      @leftTime -= time
      return time

  isDone: ->
    return @leftTime == 0

class ThreadQueue
  constructor: ->
    @threads = []

  enqueue: (thread) ->
    @threads.push thread

  dequeue: ->
    return @threads.splice(0, 1)[0]

  any: ->
    return @threads.length > 0


scheduleThreads = (params) ->
  pendingEvents = []
  nextId = 0
  for t in params.threads
    insertEvent pendingEvents,
      time: t.createTime
      type: 'createThread'
      thread: t
      id: ++nextId

  events = []
  freeCpus = new CpuSet(params.totalCpus)
  threads = new ThreadQueue()

  tryStartThread = (currentTime) ->
    if freeCpus.any() and threads.any()
      cpu = freeCpus.takeCpu()
      thread = threads.dequeue()
      time = thread.run(params.maximumTime)
      events.push
        time: currentTime
        type: 'assignCpu'
        length: time
        cpu: cpu
        thread: thread.params
      insertEvent pendingEvents,
        time: event.time + time
        type: 'assignCpuFinish'
        cpu: cpu
        thread: thread

  guard = 0
  while pendingEvents.length != 0
    event = pendingEvents.splice(0, 1)[0]
    if event.type == 'createThread'
      events.push event
      threads.enqueue(new Thread(event.id, event.thread))
      tryStartThread(event.time)
    if event.type == 'assignCpuFinish'
      freeCpus.putCpu event.cpu
      if !event.thread.isDone()
        threads.enqueue event.thread
      events.push event
      tryStartThread(event.time)
    if guard++ > 1000
      throw new Error()

  return events

schedule = scheduleThreads
  threads: [
    {createTime: 0, length: 3, color: 'green'}
    {createTime: 0, length: 10, color: 'yellow'}
    {createTime: 0, length: 13, color: 'red'}
    {createTime: 0, length: 17, color: 'black'}
    {createTime: 10, length: 17, color: 'brown'}
    {createTime: 50, length: 17, color: 'blue'}
  ]
  totalCpus: 3
  maximumTime: 5


class MyStage1 extends draw.MyStage
  constructor: (@id) ->
    super(@id)

    @scale = 4

    image = new draw.Image('images/tux.svg')
    image.scale = 0.2
    image.x = 100

    # rect = new draw.Rectangle(20, 40)

    @addChild image
    # @addChild rect

    @drawThreads schedule

    @update()

  drawThreads: (schedule) ->
    for e in schedule
      if e.type == 'assignCpu'
        timeScale = 4
        rect = new draw.Rectangle(e.length*timeScale - 2, 9, e.thread.color)
        rect.x = e.time*timeScale
        rect.y = e.cpu.id * 10
        @addChild rect



_globals.do = ->
  new MyStage1('demo1')
