(function() {
  var Line, LineSnappingPrimitive, MovementProvider, MultiSnapping, MyStage1, MyStage10, MyStage2, MyStage3, MyStage4, MyStage5, MyStage6, MyStage7, MyStage8, MyStage9, PanMovementProvider, RotateMovementProvider, SnappingPrimitive, SnapsDictionary, draw, num,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  draw = _globals.draw;

  num = _globals.num;

  Line = (function() {
    function Line(start1, end, movable) {
      this.start = start1;
      this.end = end;
      this.movable = movable != null ? movable : false;
      this.line = new draw.Line();
      this.line.stroke = 'black';
      this.line.start = this.start;
      this.line.end = this.end;
      if (!this.movable) {
        this.shape = this.line;
      } else {
        this.shape = new draw.Container();
        this.shape.addShape(this.line);
        this.gizmo1 = new draw.Rectangle(6, 6, 'yellow');
        this.gizmo1.setPosition(this.start);
        this.shape.addShape(this.gizmo1);
        this.gizmo2 = new draw.Rectangle(6, 6, 'yellow');
        this.gizmo2.setPosition(this.end);
        this.shape.addShape(this.gizmo2);
      }
      this.primitive = new LineSnappingPrimitive();
      this.primitive.start = this.start;
      this.primitive.end = this.end;
    }

    Line.prototype.onMouseDown = function(globalPosition) {
      var gizmo1Position, gizmo2Position;
      gizmo1Position = this.gizmo1.shape.globalToLocal(globalPosition.x, globalPosition.y);
      if (this.gizmo1.shape.hitTest(gizmo1Position.x, gizmo1Position.y)) {
        this.movingGizmo = this.gizmo1;
        return true;
      }
      gizmo2Position = this.gizmo2.shape.globalToLocal(globalPosition.x, globalPosition.y);
      if (this.gizmo2.shape.hitTest(gizmo2Position.x, gizmo2Position.y)) {
        this.movingGizmo = this.gizmo2;
        return true;
      }
      return false;
    };

    Line.prototype.onMouseMove = function(stagePosition) {
      if (this.movingGizmo) {
        if (this.movingGizmo === this.gizmo1) {
          this.start = stagePosition;
        } else {
          this.end = stagePosition;
        }
        this.line.start = this.start;
        this.line.end = this.end;
        this.primitive.start = this.start;
        this.primitive.end = this.end;
        this.movingGizmo.setPosition(stagePosition);
        this.shape.update();
        return true;
      }
      return false;
    };

    Line.prototype.onMouseUp = function() {
      return this.movingGizmo = null;
    };

    Line.prototype.setSnapped = function(snapped) {
      if (snapped) {
        return this.line.stroke = 'red';
      } else {
        return this.line.stroke = 'black';
      }
    };

    return Line;

  })();

  SnappingPrimitive = (function() {
    function SnappingPrimitive() {}

    SnappingPrimitive.prototype.getNearestPoint = function(point) {
      throw new Error('abstract');
    };

    SnappingPrimitive.prototype.moveBy = function(delta) {
      throw new Error('abstract');
    };

    return SnappingPrimitive;

  })();

  LineSnappingPrimitive = (function() {
    function LineSnappingPrimitive(start1, end) {
      this.start = start1;
      this.end = end;
    }

    LineSnappingPrimitive.prototype.getNearestPoint = function(point) {
      var l2, t;
      l2 = this.end.distanceToSquared(this.start);
      if (l2 < 0.01) {
        return this.start.lerpTo(this.end);
      }
      t = point.subtract(this.start).dot(this.end.subtract(this.start)) / l2;
      if (t < 0) {
        return this.start;
      }
      if (t > 1) {
        return this.end;
      }
      return this.start.lerpTo(this.end, t);
    };

    LineSnappingPrimitive.prototype.findIntersectionPoint = function(p2) {
      var p, q, r, s, t;
      p = this.start;
      q = p2.start;
      r = this.end.subtract(this.start);
      s = p2.end.subtract(p2.start);
      t = q.subtract(p).cross(s) / r.cross(s);
      if (t < 0 || t > 1) {
        return null;
      }
      return this.start.lerpTo(this.end, t);
    };

    LineSnappingPrimitive.prototype.moveBy = function(delta) {
      return new LineSnappingPrimitive(this.start.add(delta), this.end.add(delta));
    };

    LineSnappingPrimitive.prototype.rotateBy = function(center, angle) {
      return new LineSnappingPrimitive(this.start.rotateAround(center, angle), this.end.rotateAround(center, angle));
    };

    return LineSnappingPrimitive;

  })();

  MyStage1 = (function(superClass) {
    extend(MyStage1, superClass);

    function MyStage1(id1) {
      var startLine;
      this.id = id1;
      MyStage1.__super__.constructor.call(this, this.id);
      this.zoom = 2;
      this._updateTransform();
      this.start = new num.Num2(30, 50);
      startLine = this.start.add(-0.5);
      this.line1 = new draw.Line();
      this.line1.stroke = 'black';
      this.line1.start = startLine;
      this.line1.end = startLine.add(100, 0);
      this.line2 = new draw.Line();
      this.line2.stroke = 'black';
      this.line2.start = startLine;
      this.line2.end = startLine.add(0, 100);
      this.square = new draw.Rectangle();
      this.square.setPosition(this.start.add(20));
      this.square.width = 20;
      this.square.height = 30;
      this.square.fill = 'red';
      this.square.markMovable(this._stage);
      this.addShape(this.line1);
      this.addShape(this.line2);
      this.addShape(this.square);
      this.text = new draw.Text('Put square precisely in the corner.\n it will become green when(if) you succeed', '20px Gochi Hand');
      this._stage.addChild(this.text.shape);
      this.arrow = new draw.Arrow({
        x: 10,
        y: 40
      }, this.start);
      this.arrow.stroke = 'black';
      this.addShape(this.arrow);
      this._stage.update();
    }

    MyStage1.prototype.onLogicUpdate = function() {
      var position;
      position = this.square.getTopLeftCorner();
      if (num.epsilonEquals(position.x, this.start.x, 0.1) && num.epsilonEquals(position.y, this.start.y, 0.1)) {
        return this.square.setFill('green');
      } else {
        return this.square.setFill('red');
      }
    };

    return MyStage1;

  })(draw.MyStage);

  MyStage2 = (function(superClass) {
    extend(MyStage2, superClass);

    function MyStage2(id) {
      MyStage2.__super__.constructor.call(this, id);
      this.snapTo = [];
    }

    MyStage2.prototype.snap = function() {
      var position;
      position = this.square.getTopLeftCorner();
      if (position.distanceTo(this.start) < 10) {
        return this.start.subtract(position);
      }
      return num.Num2.zero;
    };

    return MyStage2;

  })(MyStage1);

  MyStage3 = (function(superClass) {
    extend(MyStage3, superClass);

    function MyStage3(id) {
      var p, p1;
      MyStage3.__super__.constructor.call(this, id);
      p = new LineSnappingPrimitive();
      p.start = this.start;
      p.end = this.start.add(100, 0);
      p1 = new LineSnappingPrimitive();
      p1.start = this.start;
      p1.end = this.start.add(0, 100);
      this.snapTo = [p, p1];
    }

    MyStage3.prototype.snap = function() {
      var distance, k, l, len, len1, minDistance, nearest, nearestSnap, p, point, points, ref, snaps;
      minDistance = 10;
      points = this.square.getSnappingPoints();
      snaps = [];
      for (k = 0, len = points.length; k < len; k++) {
        point = points[k];
        ref = this.snapTo;
        for (l = 0, len1 = ref.length; l < len1; l++) {
          p = ref[l];
          nearest = p.getNearestPoint(point);
          distance = nearest.distanceTo(point);
          if (distance < minDistance) {
            snaps.push({
              nearest: nearest,
              point: point,
              distance: distance
            });
          }
        }
      }
      nearestSnap = _.min(snaps, function(snap) {
        return snap.distance;
      });
      if (nearestSnap === Infinity) {
        return num.Num2.zero;
      }
      return nearestSnap.nearest.subtract(nearestSnap.point);
    };

    return MyStage3;

  })(MyStage1);

  MyStage4 = (function(superClass) {
    extend(MyStage4, superClass);

    function MyStage4(id, suppressShapes) {
      var line1, line2, pt;
      if (suppressShapes == null) {
        suppressShapes = false;
      }
      MyStage4.__super__.constructor.call(this, id);
      if (!suppressShapes) {
        line1 = new Line(new num.Num2(0, 0), new num.Num2(100, 0));
        line2 = new Line(new num.Num2(0, 0), new num.Num2(0, 100));
        this.snapTo = [line1.primitive, line2.primitive];
        pt = line1.primitive.findIntersectionPoint(line2.primitive);
        this.square = new draw.Rectangle();
        this.square.setPosition(new num.Num2(0, 0).add(20));
        this.square.width = 20;
        this.square.height = 30;
        this.square.fill = 'red';
        this.square.markMovable(this._stage);
        this.addShape(line1.shape);
        this.addShape(line2.shape);
        this.addShape(this.square);
      }
    }

    MyStage4.prototype.snap = function() {
      var distance, i, intersection, intersections, j, k, l, len, len1, len2, len3, m, minDistance, nearest, nearestSnap, o, p, point, points, ref, ref1, ref2, ref3, snaps, u, v;
      minDistance = 10;
      points = this.square.getSnappingPoints();
      snaps = [];
      for (k = 0, len = points.length; k < len; k++) {
        point = points[k];
        ref = this.snapTo;
        for (l = 0, len1 = ref.length; l < len1; l++) {
          p = ref[l];
          nearest = p.getNearestPoint(point);
          distance = nearest.distanceTo(point);
          if (distance < minDistance) {
            snaps.push({
              nearest: nearest,
              point: point,
              distance: distance,
              weight: 1
            });
          }
        }
      }
      intersections = [];
      for (i = m = 0, ref1 = this.snapTo.length - 1; m <= ref1; i = m += 1) {
        for (j = o = ref2 = i + 1, ref3 = this.snapTo.length - 1; o <= ref3; j = o += 1) {
          intersection = this.snapTo[i].findIntersectionPoint(this.snapTo[j]);
          if (intersection) {
            intersections.push(intersection);
          }
        }
      }
      for (u = 0, len2 = points.length; u < len2; u++) {
        point = points[u];
        for (v = 0, len3 = intersections.length; v < len3; v++) {
          p = intersections[v];
          nearest = p;
          distance = nearest.distanceTo(point);
          if (distance < minDistance) {
            snaps.push({
              nearest: nearest,
              point: point,
              distance: distance,
              weight: 100
            });
          }
        }
      }
      nearestSnap = _.min(snaps, function(snap) {
        return Math.max(snap.distance, 5) / snap.weight;
      });
      if (nearestSnap === Infinity || nearestSnap === -Infinity) {
        return num.Num2.zero;
      }
      return nearestSnap.nearest.subtract(nearestSnap.point);
    };

    return MyStage4;

  })(draw.MyStage);

  MyStage5 = (function(superClass) {
    extend(MyStage5, superClass);

    function MyStage5(id) {
      var line1, line2;
      MyStage5.__super__.constructor.call(this, id, true);
      line1 = new Line(new num.Num2(0, 0), new num.Num2(100, 100));
      line2 = new Line(new num.Num2(100, 0), new num.Num2(0, 100));
      this.snapTo = [line1.primitive, line2.primitive];
      this.square0 = new draw.Rectangle();
      this.square0.setPosition(new num.Num2(75, 50));
      this.square0.width = 20;
      this.square0.height = 30;
      this.square0.fill = 'green';
      this.square0.shape.alpha = 0.3;
      this.text = new draw.Text('Ideally you would like to put it as green square shows...', '11px Gochi Hand');
      this.text.setPosition(new num.Num2(90, 40));
      this.square = new draw.Rectangle();
      this.square.setPosition(new num.Num2(0, 0).add(20));
      this.square.width = 20;
      this.square.height = 30;
      this.square.fill = 'red';
      this.square.markMovable(this._stage);
      this.addShape(line1.shape);
      this.addShape(line2.shape);
      this.addShape(this.square0);
      this.addShape(this.square);
      this.addShape(this.text);
    }

    return MyStage5;

  })(MyStage4);

  MyStage6 = (function(superClass) {
    extend(MyStage6, superClass);

    function MyStage6(id) {
      var intersection, line1, line2, squarePoints;
      MyStage6.__super__.constructor.call(this, id, true);
      line1 = new Line(new num.Num2(0, 0), new num.Num2(100, 100));
      line2 = new Line(new num.Num2(100, 0), new num.Num2(0, 100));
      this.square0 = new draw.Rectangle();
      this.square0.setPosition(new num.Num2(100, 50));
      this.square0.width = 20;
      this.square0.height = 30;
      this.square0.fill = 'red';
      squarePoints = this.square0.getSnappingPoints();
      this.arrow1 = new draw.Arrow(squarePoints[0], line2.primitive.getNearestPoint(squarePoints[0]));
      this.arrow2 = new draw.Arrow(squarePoints[2], line1.primitive.getNearestPoint(squarePoints[2]));
      this.arrow3 = new draw.Arrow(squarePoints[0], squarePoints[0].subtract(24, 0), 'green');
      this.arrow4 = new draw.Arrow(squarePoints[2], squarePoints[2].subtract(24, 0), 'green');
      intersection = line2.primitive.findIntersectionPoint(line1.primitive);
      this.arrow5 = new draw.Arrow(squarePoints[0], intersection);
      this.arrow6 = new draw.Arrow(squarePoints[2], intersection);
      this.text = new draw.Text('Black arrows show how current algorithm can snap the points', '10px Gochi Hand');
      this.text.setPosition(new num.Num2(90, 20));
      this.text2 = new draw.Text('Green arrows show how we want to snap them.', '10px Gochi Hand');
      this.text2.setPosition(new num.Num2(90, 30));
      this.addShape(this.arrow1);
      this.addShape(this.arrow2);
      this.addShape(this.arrow3);
      this.addShape(this.arrow4);
      this.addShape(this.arrow5);
      this.addShape(this.arrow6);
      this.addShape(line1.shape);
      this.addShape(line2.shape);
      this.addShape(this.square0);
      this.addShape(this.text);
      this.addShape(this.text2);
    }

    return MyStage6;

  })(draw.MyStage);

  MyStage7 = (function(superClass) {
    extend(MyStage7, superClass);

    function MyStage7(id) {
      var line1, line2, squarePoints, time, tl;
      MyStage7.__super__.constructor.call(this, id, true);
      line1 = new Line(new num.Num2(0, 0), new num.Num2(100, 100));
      line2 = new Line(new num.Num2(100, 0), new num.Num2(0, 100));
      this.square0 = new draw.Rectangle();
      this.square0.setPosition(new num.Num2(100, 50));
      this.square0.width = 20;
      this.square0.height = 30;
      this.square0.fill = 'red';
      squarePoints = this.square0.getSnappingPoints();
      this.arrow1 = new draw.Arrow(squarePoints[0], line2.primitive.getNearestPoint(squarePoints[0]));
      this.arrow2 = new draw.Arrow(squarePoints[2], line1.primitive.getNearestPoint(squarePoints[2]));
      this.arrow3 = new draw.Arrow(squarePoints[0], squarePoints[0].subtract(24, 0), 'green');
      this.arrow4 = new draw.Arrow(squarePoints[2], squarePoints[2].subtract(24, 0), 'green');
      this.text = new draw.Text('Move point, together with line, to which it is snapped to another point!', '10px Gochi Hand');
      this.text.setPosition(new num.Num2(90, 20));
      TweenMax.ticker.addEventListener('tick', (function(_this) {
        return function(e) {
          return _this._stage.update();
        };
      })(this));
      time = 3;
      tl = new TimelineMax();
      tl.to(this.arrow1.shape, time, {
        y: 30
      }, 'g');
      tl.to(this.arrow3.shape, time, {
        y: 30
      }, 'g');
      tl.to(line2.shape.shape, time, {
        y: 30
      }, 'g');
      tl.delay(0.5);
      tl.repeat(-1);
      tl.repeatDelay(0.5);
      this.addShape(this.arrow1);
      this.addShape(this.arrow2);
      this.addShape(this.arrow3);
      this.addShape(this.arrow4);
      this.addShape(line1.shape);
      this.addShape(line2.shape);
      this.addShape(this.square0);
      this.addShape(this.text);
    }

    return MyStage7;

  })(draw.MyStage);

  SnapsDictionary = (function() {
    function SnapsDictionary() {
      this.items = [];
    }

    SnapsDictionary.prototype.getByDelta = function(delta) {
      var item;
      item = _.find(this.items, function(item) {
        return item.delta.epsilonEquals(delta);
      });
      if (item) {
        return item;
      }
      return null;
    };

    SnapsDictionary.prototype.add = function(singleSnapping) {
      var existing;
      existing = this.getByDelta(singleSnapping.delta);
      if (!existing) {
        existing = new MultiSnapping(singleSnapping.delta);
        this.items.push(existing);
      }
      return existing.addSnapping(singleSnapping);
    };

    return SnapsDictionary;

  })();

  MultiSnapping = (function() {
    function MultiSnapping(delta1) {
      this.delta = delta1;
      this.snappings = [];
    }

    MultiSnapping.prototype.addSnapping = function(snapping) {
      var existing;
      existing = _.find(this.snappings, function(s) {
        return s.primitive === snapping.primitive && s.point === snapping.point;
      });
      if (!existing) {
        return this.snappings.push(snapping);
      }
    };

    MultiSnapping.prototype.getValue = function() {
      return this.snappings.length * 10000000 / Math.max(this.delta.length(), 1);
    };

    return MultiSnapping;

  })();

  MyStage8 = (function(superClass) {
    extend(MyStage8, superClass);

    function MyStage8(id) {
      var line1, line2, line3, line4;
      MyStage8.__super__.constructor.call(this, id, true);
      line1 = new Line(new num.Num2(0, 0), new num.Num2(100, 100));
      line2 = new Line(new num.Num2(100, 0), new num.Num2(0, 100));
      line3 = new Line(new num.Num2(0, 0), new num.Num2(100, 0));
      line4 = new Line(new num.Num2(0, 0), new num.Num2(0, 100));
      this.snapTo = [line1.primitive, line2.primitive, line3.primitive, line4.primitive];
      this.text = new draw.Text('Now you can put it anywhere!', '11px Gochi Hand');
      this.text.setPosition(new num.Num2(90, 40));
      this.square = new draw.Rectangle();
      this.square.setPosition(new num.Num2(0, 0).add(20));
      this.square.width = 20;
      this.square.height = 30;
      this.square.fill = 'red';
      this.square.markMovable(this._stage);
      this.addShape(line1.shape);
      this.addShape(line2.shape);
      this.addShape(line3.shape);
      this.addShape(line4.shape);
      this.addShape(this.square);
      this.addShape(this.text);
    }

    MyStage8.prototype.snap = function() {
      var delta, firstSnap, i, intersection, j, k, l, len, len1, len2, m, minDistance, movedSecondSnap, nearest, nearestSnap, o, p, point, points, pointsDelta, ref, ref1, ref2, ref3, secondSnap, singleSnaps, snap, snaps, u;
      minDistance = 20;
      points = this.square.getSnappingPoints();
      singleSnaps = [];
      for (k = 0, len = points.length; k < len; k++) {
        point = points[k];
        ref = this.snapTo;
        for (l = 0, len1 = ref.length; l < len1; l++) {
          p = ref[l];
          nearest = p.getNearestPoint(point);
          delta = nearest.subtract(point);
          if (delta.length() < minDistance) {
            singleSnaps.push({
              point: point,
              delta: delta,
              primitive: p
            });
          }
        }
      }
      snaps = new SnapsDictionary();
      for (m = 0, len2 = singleSnaps.length; m < len2; m++) {
        snap = singleSnaps[m];
        snaps.add(snap);
      }
      for (i = o = 0, ref1 = singleSnaps.length - 1; o <= ref1; i = o += 1) {
        firstSnap = singleSnaps[i];
        for (j = u = ref2 = i + 1, ref3 = singleSnaps.length - 1; u <= ref3; j = u += 1) {
          secondSnap = singleSnaps[j];
          if (!firstSnap.delta.epsilonEquals(secondSnap.delta)) {
            pointsDelta = firstSnap.point.subtract(secondSnap.point);
            movedSecondSnap = secondSnap.primitive.moveBy(pointsDelta);
            intersection = movedSecondSnap.findIntersectionPoint(firstSnap.primitive);
            if (intersection) {
              delta = intersection.subtract(firstSnap.point);
              snaps.add({
                delta: delta,
                point: firstSnap.point,
                primitive: firstSnap.primitive
              });
              snaps.add({
                delta: delta,
                point: secondSnap.point,
                primitive: secondSnap.primitive
              });
            }
          }
        }
      }
      nearestSnap = _.max(snaps.items, function(snap) {
        return snap.getValue();
      });
      if (nearestSnap === Infinity || nearestSnap === -Infinity) {
        return num.Num2.zero;
      }
      return nearestSnap.delta;
    };

    return MyStage8;

  })(MyStage4);

  MovementProvider = (function() {
    function MovementProvider() {}

    MovementProvider.prototype.getNearestPoint = function(primitive, point) {
      throw new Error();
    };

    MovementProvider.prototype.getMouseDelta = function(projection, point) {
      throw new Error();
    };

    MovementProvider.prototype.combineSnappings = function(firstSnap, secondSnap) {
      throw new Error();
    };

    return MovementProvider;

  })();

  PanMovementProvider = (function() {
    function PanMovementProvider() {}

    PanMovementProvider.prototype.getNearestPoints = function(primitive, point) {
      return [primitive.getNearestPoint(point)];
    };

    PanMovementProvider.prototype.getMouseDelta = function(projection, point) {
      return projection.subtract(point);
    };

    PanMovementProvider.prototype.combineSnappings = function(firstSnap, secondSnap) {
      var intersection, movedSecondSnap, pointsDelta;
      pointsDelta = firstSnap.point.subtract(secondSnap.point);
      movedSecondSnap = secondSnap.primitive.moveBy(pointsDelta);
      intersection = movedSecondSnap.findIntersectionPoint(firstSnap.primitive);
      if (intersection) {
        return intersection.subtract(firstSnap.point);
      }
      return null;
    };

    return PanMovementProvider;

  })();

  RotateMovementProvider = (function() {
    function RotateMovementProvider(center1) {
      this.center = center1;
    }

    RotateMovementProvider.prototype.getNearestPoints = function(primitive, point) {
      var intersections, radius;
      radius = this.center.distanceTo(point);
      intersections = num.findLineSegmentCircleIntersections(primitive.start, primitive.end, this.center.x, this.center.y, radius);
      return intersections;
    };

    RotateMovementProvider.prototype._getMouseDelta = function(angle) {
      var snappedPosition;
      snappedPosition = this.mousePosition.rotateAround(this.center, angle);
      return snappedPosition.subtract(this.mousePosition);
    };

    RotateMovementProvider.prototype.getMouseDelta = function(projection, point) {
      var angle, v1, v2;
      if (projection.x === void 0) {
        throw new Error();
      }
      v1 = num.Num2.vectorFromPoints(this.center, projection);
      v2 = num.Num2.vectorFromPoints(this.center, point);
      angle = v2.angleTo(v1);
      return this._getMouseDelta(angle);
    };

    RotateMovementProvider.prototype.combineSnappings = function(firstSnap, secondSnap) {
      var angle, intersection, movedSecondSnap, v1, v2;
      v1 = num.Num2.vectorFromPoints(this.center, firstSnap.point);
      v2 = num.Num2.vectorFromPoints(this.center, secondSnap.point);
      angle = v2.angleTo(v1);
      movedSecondSnap = secondSnap.primitive.rotateBy(this.center, angle);
      intersection = movedSecondSnap.findIntersectionPoint(firstSnap.primitive);
      if (intersection && intersection.epsilonEquals(firstSnap.point)) {
        return this.getMouseDelta(intersection, firstSnap.point);
      }
      return null;
    };

    return RotateMovementProvider;

  })();

  MyStage9 = (function(superClass) {
    extend(MyStage9, superClass);

    function MyStage9(id) {
      var line1, line2, squarePoints, start;
      MyStage9.__super__.constructor.call(this, id, true);
      start = new num.Num2(85, 32);
      line1 = new draw.Line(start, start.add(100, 0));
      line2 = new draw.Line(start, start.add(0, 100));
      this.square0 = new draw.Rectangle(70, 70, 'red');
      this.square0.setPosition(new num.Num2(100, 50));
      squarePoints = this.square0.getSnappingPoints();
      this.text = new draw.Text('Move point, together with line, to which it is snapped to another point!', '10px Gochi Hand');
      this.text.setPosition(new num.Num2(90, 20));
      this.addShape(line1);
      this.addShape(line2);
      this.addShape(this.square0);
      this.addShape(this.text);
    }

    return MyStage9;

  })(draw.MyStage);

  MyStage10 = (function(superClass) {
    extend(MyStage10, superClass);

    function MyStage10(id1) {
      var line1, line2, startLine;
      this.id = id1;
      MyStage10.__super__.constructor.call(this, this.id, true);
      this.zoom = 2;
      this._updateTransform();
      this.lines = [];
      this.snapTo = [];
      this.start = new num.Num2(30, 50);
      startLine = this.start.add(-0.5);
      line1 = new Line(new num.Num2(0, 0), new num.Num2(100, 0), true);
      line2 = new Line(new num.Num2(0, 0), new num.Num2(0, 100), true);
      this.square = new draw.Rectangle();
      this.square.setPosition(num.Num2.zero.add(10, 15));
      this.square.width = 20;
      this.square.height = 30;
      this.square.fill = 'red';
      this.square.markRotatable();
      this.square.movementProvider = new RotateMovementProvider(this.square.getCenter());
      this.square0 = new draw.Rectangle();
      this.square0.setPosition(this.start.add(40));
      this.square0.width = 20;
      this.square0.height = 30;
      this.square0.fill = 'red';
      this.square0.markMovable();
      this.square0.movementProvider = new PanMovementProvider();
      this.addShape(this.square);
      this.addShape(this.square0);
      this.addSnapLine(line1);
      this.addSnapLine(line2);
      this._stage.update();
    }

    MyStage10.prototype.addSnapLine = function(line) {
      this.addShape(line.shape);
      this.snapTo.push(line.primitive);
      return this.lines.push(line);
    };

    MyStage10.prototype.onMouseDown = function(e) {
      var handled, k, len, ref, s, stagePosition;
      handled = false;
      if (e.nativeEvent.which === 1) {
        stagePosition = new num.Num2(e.rawX, e.rawY);
        ref = this.lines;
        for (k = 0, len = ref.length; k < len; k++) {
          s = ref[k];
          if (s.onMouseDown(stagePosition)) {
            handled = true;
            break;
          }
        }
      }
      if (!handled) {
        return MyStage10.__super__.onMouseDown.call(this, e);
      }
    };

    MyStage10.prototype.onMouseMove = function(e) {
      var handled, k, len, ref, s, stagePosition;
      handled = false;
      stagePosition = new num.Num2(this._stage.globalToLocal(e.rawX, e.rawY));
      ref = this.lines;
      for (k = 0, len = ref.length; k < len; k++) {
        s = ref[k];
        if (s.onMouseMove(stagePosition)) {
          handled = true;
          break;
        }
      }
      if (!handled) {
        return MyStage10.__super__.onMouseMove.call(this, e);
      } else {
        return this._stage.update();
      }
    };

    MyStage10.prototype.onMouseUp = function(e) {
      var k, len, ref, s;
      ref = this.lines;
      for (k = 0, len = ref.length; k < len; k++) {
        s = ref[k];
        s.onMouseUp();
      }
      return MyStage10.__super__.onMouseUp.call(this, e);
    };

    MyStage10.prototype.snap = function() {
      var delta, firstSnap, i, intersectionDelta, j, k, l, len, len1, len2, len3, m, minDistance, movementProvider, n, nearest, nearestSnap, o, p, point, points, ref, ref1, ref2, ref3, secondSnap, singleSnaps, snap, snaps, u, v;
      minDistance = 20;
      points = this.getSnappingShape().wrapper.getSnappingPoints();
      movementProvider = this.getSnappingShape().wrapper.movementProvider;
      movementProvider.mousePosition = this.mousePosition;
      singleSnaps = [];
      for (k = 0, len = points.length; k < len; k++) {
        point = points[k];
        ref = this.snapTo;
        for (l = 0, len1 = ref.length; l < len1; l++) {
          p = ref[l];
          nearest = movementProvider.getNearestPoints(p, point);
          for (m = 0, len2 = nearest.length; m < len2; m++) {
            n = nearest[m];
            delta = movementProvider.getMouseDelta(n, point);
            if (delta.length() < minDistance) {
              singleSnaps.push({
                point: point,
                delta: delta,
                primitive: p
              });
            }
          }
        }
      }
      snaps = new SnapsDictionary();
      for (o = 0, len3 = singleSnaps.length; o < len3; o++) {
        snap = singleSnaps[o];
        snaps.add(snap);
      }
      for (i = u = 0, ref1 = singleSnaps.length - 1; u <= ref1; i = u += 1) {
        firstSnap = singleSnaps[i];
        for (j = v = ref2 = i + 1, ref3 = singleSnaps.length - 1; v <= ref3; j = v += 1) {
          secondSnap = singleSnaps[j];
          if (!firstSnap.delta.epsilonEquals(secondSnap.delta)) {
            intersectionDelta = movementProvider.combineSnappings(firstSnap, secondSnap);
            if (intersectionDelta) {
              delta = intersectionDelta;
              snaps.add({
                delta: delta,
                point: firstSnap.point,
                primitive: firstSnap.primitive
              });
              snaps.add({
                delta: delta,
                point: secondSnap.point,
                primitive: secondSnap.primitive
              });
            }
          }
        }
      }
      nearestSnap = _.max(snaps.items, function(snap) {
        return snap.getValue();
      });
      if (nearestSnap === Infinity || nearestSnap === -Infinity) {
        return num.Num2.zero;
      }
      return nearestSnap.delta;
    };

    return MyStage10;

  })(draw.MyStage);

  _globals["do"] = function() {
    new MyStage1('demo1');
    new MyStage2('demo2');
    new MyStage3('demo3');
    new MyStage4('demo4');
    new MyStage5('demo5');
    new MyStage6('demo6');
    new MyStage7('demo7');
    new MyStage8('demo8');
    new MyStage9('demo9');
    return new MyStage10('demo10');
  };

}).call(this);
