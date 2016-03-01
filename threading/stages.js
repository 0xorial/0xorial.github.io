(function() {
  var MyStage1, draw, num, schedule, scheduler,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  draw = _globals.draw;

  num = _globals.num;

  scheduler = _globals.scheduler;

  schedule = scheduler.scheduleThreads({
    threads: [
      {
        createTime: 0,
        length: 3,
        color: 'green'
      }, {
        createTime: 0,
        length: 10,
        color: 'yellow'
      }, {
        createTime: 0,
        length: 13,
        color: 'red'
      }, {
        createTime: 0,
        length: 17,
        color: 'black'
      }, {
        createTime: 10,
        length: 17,
        color: 'brown'
      }, {
        createTime: 50,
        length: 17,
        color: 'blue'
      }
    ],
    totalCpus: 2,
    maximumTime: 5
  });

  MyStage1 = (function(_super) {
    __extends(MyStage1, _super);

    function MyStage1(id) {
      var image;
      this.id = id;
      MyStage1.__super__.constructor.call(this, this.id);
      this.scale = 1;
      image = new draw.Image('images/tux.svg');
      image.scale = 0.2;
      image.x = 100;
      this.addChild(image);
      this.drawThreads(schedule);
      this.update();
    }

    MyStage1.prototype.drawThreads = function(schedule) {
      var container, e, rect, rowHeight, timeScale, _i, _len;
      container = new createjs.Container();
      rowHeight = 50;
      timeScale = 10;
      for (_i = 0, _len = schedule.length; _i < _len; _i++) {
        e = schedule[_i];
        if (e.type === 'assignCpu') {
          rect = new draw.Rectangle(e.length * timeScale - 2, rowHeight - rowHeight * 0.4, e.thread.color);
          rect.x = e.time * timeScale;
          rect.y = e.cpu.id * rowHeight;
          container.addChild(rect);
        }
      }
      this.addChild(container);
      return container.position = new num.Num2(200, 50);
    };

    return MyStage1;

  })(draw.MyStage);

  _globals["do"] = function() {
    return new MyStage1('demo1');
  };

}).call(this);
