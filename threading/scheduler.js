(function() {
  var CpuSet, Thread, ThreadQueue, exports, insertEvent;

  if (!exports) {
    exports = {};
  }

  _globals.scheduler = exports;

  insertEvent = function(array, event) {
    var e, insertAt, _i, _len;
    insertAt = 0;
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      e = array[_i];
      if (e.time > event.time) {
        break;
      }
      insertAt++;
    }
    return array.splice(insertAt, 0, event);
  };

  CpuSet = (function() {
    function CpuSet(count) {
      var i, _i, _ref;
      this.cpus = [];
      for (i = _i = 0, _ref = count - 1; _i <= _ref; i = _i += 1) {
        this.cpus.push({
          id: i
        });
      }
    }

    CpuSet.prototype.freeCpusCount = function() {
      return this.cpus.length;
    };

    CpuSet.prototype.takeCpu = function(preferredCpu) {
      var cpuIndex;
      cpuIndex = 0;
      if (preferredCpu !== void 0) {
        cpuIndex = _.findIndex(this.cpus, (function(_this) {
          return function(c) {
            return c.id === preferredCpu.id;
          };
        })(this));
      }
      if (cpuIndex < 0) {
        cpuIndex = 0;
      }
      return this.cpus.splice(cpuIndex, 1)[0];
    };

    CpuSet.prototype.putCpu = function(cpu) {
      return this.cpus.push(cpu);
    };

    CpuSet.prototype.any = function() {
      return this.freeCpusCount() > 0;
    };

    return CpuSet;

  })();

  Thread = (function() {
    function Thread(id, params) {
      this.id = id;
      this.params = params;
      this.totalTime = this.params.length;
      this.leftTime = this.totalTime;
    }

    Thread.prototype.run = function(time) {
      var took;
      if (this.leftTime <= time) {
        took = this.leftTime;
        this.leftTime = 0;
        return took;
      } else {
        this.leftTime -= time;
        return time;
      }
    };

    Thread.prototype.isDone = function() {
      return this.leftTime === 0;
    };

    return Thread;

  })();

  ThreadQueue = (function() {
    function ThreadQueue() {
      this.threads = [];
    }

    ThreadQueue.prototype.enqueue = function(thread) {
      return this.threads.push(thread);
    };

    ThreadQueue.prototype.dequeue = function() {
      return this.threads.splice(0, 1)[0];
    };

    ThreadQueue.prototype.any = function() {
      return this.threads.length > 0;
    };

    return ThreadQueue;

  })();

  exports.scheduleThreads = function(params) {
    var event, events, freeCpus, guard, nextId, pendingEvents, t, threads, tryStartThread, _i, _len, _ref;
    pendingEvents = [];
    nextId = 0;
    _ref = params.threads;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      t = _ref[_i];
      insertEvent(pendingEvents, {
        time: t.createTime,
        type: 'createThread',
        thread: t,
        id: ++nextId
      });
    }
    events = [];
    freeCpus = new CpuSet(params.totalCpus);
    threads = new ThreadQueue();
    tryStartThread = function(currentTime) {
      var cpu, thread, time;
      if (freeCpus.any() && threads.any()) {
        thread = threads.dequeue();
        cpu = freeCpus.takeCpu(thread.lastCpu);
        thread.lastCpu = cpu;
        time = thread.run(params.maximumTime);
        events.push({
          time: currentTime,
          type: 'assignCpu',
          length: time,
          cpu: cpu,
          thread: thread.params
        });
        return insertEvent(pendingEvents, {
          time: event.time + time,
          type: 'assignCpuFinish',
          cpu: cpu,
          thread: thread
        });
      }
    };
    guard = 0;
    while (pendingEvents.length !== 0) {
      event = pendingEvents.splice(0, 1)[0];
      if (event.type === 'createThread') {
        events.push(event);
        threads.enqueue(new Thread(event.id, event.thread));
        tryStartThread(event.time);
      }
      if (event.type === 'assignCpuFinish') {
        freeCpus.putCpu(event.cpu);
        if (!event.thread.isDone()) {
          threads.enqueue(event.thread);
        }
        events.push(event);
        tryStartThread(event.time);
      }
      if (guard++ > 1000) {
        throw new Error();
      }
    }
    return events;
  };

}).call(this);
