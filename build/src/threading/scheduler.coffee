if !exports
  exports = {}
_globals.scheduler = exports

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

  takeCpu: (preferredCpu) ->
    cpuIndex = 0
    if preferredCpu != undefined
      cpuIndex = _.findIndex(@cpus, (c) => c.id == preferredCpu.id)
    if cpuIndex < 0
      cpuIndex = 0
    return @cpus.splice(cpuIndex, 1)[0]

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


exports.scheduleThreads = (params) ->
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
      thread = threads.dequeue()
      cpu = freeCpus.takeCpu(thread.lastCpu)
      thread.lastCpu = cpu
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
