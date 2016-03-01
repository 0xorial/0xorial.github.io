(function() {
  var exports, num,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (!exports) {
    exports = {};
  }

  _globals.draw = exports;

  num = _globals.num;

  exports.ShapeBase = (function() {
    function ShapeBase() {}

    ShapeBase.prototype.getSnappingPoints = function() {
      return [this.getPosition()];
    };

    ShapeBase.prototype.getPosition = function() {
      return new num.Num2(this.shape.x, this.shape.y);
    };

    ShapeBase.prototype.getCenter = function() {
      return getPosition();
    };

    ShapeBase.prototype.setPosition = function(x, y) {
      if (x.x !== void 0) {
        y = x.y;
        x = x.x;
      }
      this.shape.x = x;
      this.shape.y = y;
      return this.update();
    };

    ShapeBase.prototype.update = function() {};

    return ShapeBase;

  })();

  exports.Container = (function(_super) {
    __extends(Container, _super);

    function Container() {
      this.shape = new createjs.Container();
      this.shapes = [];
    }

    Container.prototype.addShape = function(shape) {
      this.shapes.push(shape);
      return this.shape.addChild(shape.shape);
    };

    Container.prototype.removeShape = function(shape) {
      var i;
      i = this.shapes.indexOf(shape);
      this.shapes.splice(i, 1);
      return this.shape.removeChild(shape.shape);
    };

    Container.prototype.update = function() {
      var s, _i, _len, _ref, _results;
      _ref = this.shapes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        s = _ref[_i];
        _results.push(s.update());
      }
      return _results;
    };

    return Container;

  })(exports.ShapeBase);

  exports.Shape = (function(_super) {
    __extends(Shape, _super);

    function Shape() {
      this.shape = new createjs.Shape();
      this.shape.wrapper = this;
    }

    Shape.prototype._makeGraphics = function() {
      var g;
      g = this.shape.graphics;
      if (this.stroke) {
        g.beginStroke(this.stroke);
      }
      if (this.fill) {
        g.beginFill(this.fill);
      }
      return g;
    };

    Shape.prototype.setFill = function(fill) {
      this.fill = fill;
      return this.update();
    };

    Shape.prototype.setStroke = function(stroke) {
      this.stroke = stroke;
      return this.update();
    };

    Shape.prototype.update = function() {
      this.shape.graphics.clear();
      return this._makeGraphics();
    };

    Shape.prototype.markMovable = function() {
      this.shape.alpha = 0.6;
      this.shape.isPickable = true;
      return this.shape.isMovable = true;
    };

    Shape.prototype.markRotatable = function() {
      this.shape.alpha = 0.6;
      this.shape.isPickable = true;
      return this.shape.isRotatable = true;
    };

    return Shape;

  })(exports.ShapeBase);

  exports.Circle = (function(_super) {
    __extends(Circle, _super);

    function Circle() {
      return Circle.__super__.constructor.apply(this, arguments);
    }

    Circle.prototype._makeGraphics = function() {
      return Circle.__super__._makeGraphics.call(this).drawCircle(0, 0, this.radius);
    };

    return Circle;

  })(exports.Shape);

  exports.Cross = (function(_super) {
    __extends(Cross, _super);

    function Cross() {
      Cross.__super__.constructor.call(this);
      this.stroke = 'brown';
      this.position = num.Num2.zero;
    }

    Cross.prototype._makeGraphics = function() {
      var end1, end2, size, start1, start2;
      size = 5;
      start1 = this.position.subtract(size, 0);
      end1 = this.position.add(size, 0);
      start2 = this.position.subtract(0, size);
      end2 = this.position.add(0, size);
      return Cross.__super__._makeGraphics.call(this).moveTo(start1.x, start1.y).lineTo(end1.x, end1.y).moveTo(start2.x, start2.y).lineTo(end2.x, end2.y);
    };

    return Cross;

  })(exports.Shape);

  exports.Rectangle = (function(_super) {
    __extends(Rectangle, _super);

    function Rectangle(width, height, fill) {
      this.width = width;
      this.height = height;
      this.fill = fill;
      Rectangle.__super__.constructor.call(this);
    }

    Rectangle.prototype._makeGraphics = function() {
      this.shape.regX = this.width / 2;
      this.shape.regY = this.height / 2;
      return Rectangle.__super__._makeGraphics.call(this).drawRect(0, 0, this.width, this.height);
    };

    Rectangle.prototype.getTopLeftCorner = function() {
      return this.getSnappingPoints()[0];
    };

    Rectangle.prototype.getSnappingPoints = function() {
      var center, h2, point1, point2, point3, point4, pos, w2;
      pos = this.getPosition();
      w2 = this.width / 2;
      h2 = this.height / 2;
      center = pos;
      point1 = pos.add(-w2, -h2);
      point2 = pos.add(w2, -h2);
      point3 = pos.add(-w2, h2);
      point4 = pos.add(w2, h2);
      return [point1, point2, point3, point4].map((function(_this) {
        return function(p) {
          return p.rotateAroundDeg(center, _this.shape.rotation);
        };
      })(this));
    };

    Rectangle.prototype.getCenter = function() {
      return new num.Num2(this.shape.x, this.shape.y);
    };

    return Rectangle;

  })(exports.Shape);

  exports.Line = (function(_super) {
    __extends(Line, _super);

    function Line(start, end, stroke) {
      this.start = start;
      this.end = end;
      Line.__super__.constructor.call(this);
      this.stroke = 'black';
      if (stroke) {
        this.stroke = stroke;
      }
    }

    Line.prototype._makeGraphics = function() {
      return Line.__super__._makeGraphics.call(this).moveTo(this.start.x, this.start.y).lineTo(this.end.x, this.end.y);
    };

    return Line;

  })(exports.Shape);

  exports.Arrow = (function(_super) {
    __extends(Arrow, _super);

    function Arrow(start, end, stroke) {
      this.start = start;
      this.end = end;
      Arrow.__super__.constructor.call(this);
      this.stroke = 'black';
      if (stroke) {
        this.stroke = stroke;
      }
    }

    Arrow.prototype._makeGraphics = function() {
      var angle, direction, leftArrow, length, rightArrow;
      direction = Victor.fromPoints(this.start, this.end).normalize();
      angle = 150;
      length = 10;
      leftArrow = direction.clone().rotateDeg(-angle).multiplyScalar(length).add(this.end);
      rightArrow = direction.clone().rotateDeg(angle).multiplyScalar(length).add(this.end);
      return Arrow.__super__._makeGraphics.call(this).moveTo(this.start.x, this.start.y).lineTo(this.end.x, this.end.y).lineTo(leftArrow.x, leftArrow.y).lineTo(rightArrow.x, rightArrow.y).lineTo(this.end.x, this.end.y);
    };

    return Arrow;

  })(exports.Shape);

  exports.Text = (function(_super) {
    __extends(Text, _super);

    function Text(text, font) {
      this.shape = new createjs.Text(text, font);
    }

    Text.prototype.setText = function(text) {
      return this.shape.text = text;
    };

    Text.prototype.setFont = function(font) {
      return this.shape.font = font;
    };

    Text.prototype.update = function() {};

    return Text;

  })(exports.ShapeBase);

  exports.MyStage = (function() {
    function MyStage(id, showSnapCross) {
      this.id = id;
      this.showSnapCross = showSnapCross != null ? showSnapCross : false;
      this._stage = new createjs.Stage(this.id);
      this.cross = new exports.Cross();
      this._offset = new num.Num2(80, 50);
      this.zoom = 2;
      this._updateTransform();
      setInterval(((function(_this) {
        return function() {
          return _this._stage.update();
        };
      })(this)), 300);
      $("#" + this.id).on('mousewheel', (function(_this) {
        return function(event) {
          var oldZoom, point, zoom;
          event.preventDefault();
          oldZoom = _this.zoom;
          if (event.deltaY > 0) {
            _this.zoom *= 1.1;
          } else {
            _this.zoom /= 1.1;
          }
          point = new num.Num2(_this._stage.mouseX, _this._stage.mouseY);
          zoom = _this.zoom / oldZoom;
          _this._offset = _this._offset.multiply(zoom).subtract(point.multiply(zoom)).add(point);
          return _this._updateTransform();
        };
      })(this));
      this._stage.on('stagemouseup', (function(_this) {
        return function(e) {
          return _this.onMouseUp(e);
        };
      })(this));
      this._stage.on('stagemousedown', (function(_this) {
        return function(e) {
          return _this.onMouseDown(e);
        };
      })(this));
      this._stage.on('stagemousemove', (function(_this) {
        return function(e) {
          return _this.onMouseMove(e);
        };
      })(this));
    }

    MyStage.prototype.onMouseDown = function(event) {
      var shape;
      this._dragStartPosition = {
        x: event.stageX,
        y: event.stageY
      };
      this._dragStartOffset = this._offset.clone();
      if (event.nativeEvent.which === 1) {
        shape = this._pickShape(event.stageX, event.stageY);
        if (shape && shape.isMovable) {
          this._currentMovingShape = shape;
          this._shapeStartPosition = new num.Num2(shape.x, shape.y);
        }
        if (shape && shape.isRotatable) {
          this._currentRotatingShape = shape;
          this._shapeStartRotation = shape.rotation;
        }
        if (this.showSnapCross) {
          this.cross.position = new num.Num2(this._stage.globalToLocal(event.rawX, event.rawY));
          return this.addShape(this.cross);
        }
      }
    };

    MyStage.prototype.getSnappingShape = function() {
      if (this._currentMovingShape) {
        return this._currentMovingShape;
      }
      return this._currentRotatingShape;
    };

    MyStage.prototype.onMouseUp = function(event) {
      this._currentMovingShape = null;
      this._currentRotatingShape = null;
      this._dragStartPosition = null;
      return this._dragStartOffset = null;
    };

    MyStage.prototype._calculateRotation = function(centerStage, mouseStage) {
      var angleDiff, currentVector, startVector, _dragStartPosition;
      _dragStartPosition = this._stage.globalToLocal(this._dragStartPosition.x, this._dragStartPosition.y);
      startVector = num.Num2.vectorFromPoints(centerStage, _dragStartPosition);
      currentVector = num.Num2.vectorFromPoints(centerStage, mouseStage);
      angleDiff = currentVector.angleToDeg(startVector);
      return this._shapeStartRotation - angleDiff;
    };

    MyStage.prototype.onMouseMove = function(event) {
      var adjustedMousePosition, centerStage, delta, mouse, newPosition, shape, snappingDelta, zoomedDelta;
      this.mousePosition = new num.Num2(this._stage.globalToLocal(event.rawX, event.rawY));
      mouse = new num.Num2(event.stageX, event.stageY);
      if (this._dragStartPosition) {
        delta = num.Num2.subtract(mouse, this._dragStartPosition);
      }
      if (event.nativeEvent.which === 2) {
        this._offset = this._dragStartOffset.add(delta);
        this._updateTransform();
      }
      if (this._currentMovingShape) {
        zoomedDelta = delta.multiply(1 / this.zoom);
        newPosition = this._shapeStartPosition.add(zoomedDelta);
        console.log('position' + newPosition.toString());
        this._currentMovingShape.x = newPosition.x;
        this._currentMovingShape.y = newPosition.y;
        snappingDelta = this.snap();
        console.log('snapping delta' + snappingDelta.toString());
        newPosition.addThis(snappingDelta);
        adjustedMousePosition = this.mousePosition.add(snappingDelta);
        this.cross.position = new num.Num2(adjustedMousePosition);
        this.cross.update();
        console.log('new position' + newPosition.toString());
        this._currentMovingShape.x = newPosition.x;
        this._currentMovingShape.y = newPosition.y;
      } else if (this._currentRotatingShape) {
        centerStage = this._currentRotatingShape.wrapper.getCenter();
        this._currentRotatingShape.rotation = this._calculateRotation(centerStage, this.mousePosition);
        snappingDelta = this.snap();
        console.log('snapping delta' + snappingDelta.toString());
        adjustedMousePosition = this.mousePosition.add(snappingDelta);
        this.cross.position = new num.Num2(adjustedMousePosition);
        this.cross.update();
        console.log('new position' + adjustedMousePosition.toString());
        this._currentRotatingShape.rotation = this._calculateRotation(centerStage, adjustedMousePosition);
      } else {
        shape = this._pickShape(event.stageX, event.stageY);
        if (shape && !shape.isPickable) {
          shape = null;
        }
        if (shape !== this._currentHighlightShape) {
          if (this._currentHighlightShape) {
            this._currentHighlightShape.alpha = 0.6;
          }
          if (shape) {
            shape.alpha = 1;
          }
          this._currentHighlightShape = shape;
        }
      }
      this.onLogicUpdate();
      return this._stage.update();
    };

    MyStage.prototype.snap = function() {
      return num.Num2.zero;
    };

    MyStage.prototype._pickShape = function(x, y, onlyMovable) {
      var child, i, point, _i, _ref;
      if (onlyMovable == null) {
        onlyMovable = true;
      }
      for (i = _i = _ref = this._stage.children.length - 1; _i >= 0; i = _i += -1) {
        child = this._stage.children[i];
        if (!onlyMovable || child.isPickable) {
          point = child.globalToLocal(x, y);
          if (child.hitTest(point.x, point.y)) {
            return child;
          }
        }
      }
      return null;
    };

    MyStage.prototype._updateTransform = function() {
      this._stage.setTransform(this._offset.x, this._offset.y, this.zoom, this.zoom);
      return this._stage.update();
    };

    MyStage.prototype.addShape = function(shape) {
      shape.update();
      return this._stage.addChild(shape.shape);
    };

    MyStage.prototype.onLogicUpdate = function() {};

    return MyStage;

  })();

}).call(this);
