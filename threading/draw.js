(function() {
  var exports, num, positionOffset,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (!exports) {
    exports = {};
  }

  _globals.draw = exports;

  num = _globals.num;

  Object.defineProperty(createjs.DisplayObject.prototype, 'scale', {
    get: function() {
      return new num.Num2(this.scaleX, this.scaleY);
    },
    set: function(scale) {
      scale = new num.Num2(scale);
      this.scaleX = scale.x;
      return this.scaleY = scale.y;
    }
  });

  positionOffset = {
    get: function() {
      return new num.Num2(this.x, this.y);
    },
    set: function(position) {
      position = new num.Num2(position);
      this.x = position.x;
      return this.y = position.y;
    }
  };

  Object.defineProperty(createjs.DisplayObject.prototype, 'position', positionOffset);

  Object.defineProperty(createjs.DisplayObject.prototype, 'offset', positionOffset);

  exports.Image = (function(_super) {
    __extends(Image, _super);

    function Image(image) {
      Image.__super__.constructor.call(this, image);
      this.image.onload = (function(_this) {
        return function() {
          return _this.dispatchEvent('changedAsync');
        };
      })(this);
    }

    return Image;

  })(createjs.Bitmap);

  exports.Rectangle = (function(_super) {
    __extends(Rectangle, _super);

    function Rectangle(width, height, stroke) {
      this.width = width;
      this.height = height;
      this.stroke = stroke != null ? stroke : 'black';
      Rectangle.__super__.constructor.call(this);
      this.graphics.beginStroke(this.stroke).drawRect(0, 0, this.width, this.height);
    }

    return Rectangle;

  })(createjs.Shape);

  exports.MyStage = (function(_super) {
    __extends(MyStage, _super);

    function MyStage(elementId) {
      this.elementId = elementId;
      MyStage.__super__.constructor.call(this, this.elementId);
      this._updateSelf = (function(_this) {
        return function() {
          return _this.update();
        };
      })(this);
      this.scale = 2;
      $("#" + this.elementId).on('mousewheel', (function(_this) {
        return function(event) {
          var newZoom, oldZoom, point, zoomRatio;
          event.preventDefault();
          oldZoom = _this.scaleX;
          if (event.deltaY > 0) {
            newZoom = oldZoom * 1.1;
          } else {
            newZoom = oldZoom / 1.1;
          }
          point = new num.Num2(_this.mouseX, _this.mouseY);
          zoomRatio = newZoom / oldZoom;
          _this.scale = newZoom;
          _this.offset = _this.offset.multiply(zoomRatio).subtract(point.multiply(zoomRatio)).add(point);
          return _this.update();
        };
      })(this));
      this.on('stagemouseup', (function(_this) {
        return function(e) {
          return _this.onMouseUp(e);
        };
      })(this));
      this.on('stagemousedown', (function(_this) {
        return function(e) {
          return _this.onMouseDown(e);
        };
      })(this));
      this.on('stagemousemove', (function(_this) {
        return function(e) {
          return _this.onMouseMove(e);
        };
      })(this));
    }

    MyStage.prototype.onMouseDown = function(event) {
      this._dragStartPosition = {
        x: event.stageX,
        y: event.stageY
      };
      return this._dragStartOffset = this.offset.clone();
    };

    MyStage.prototype.onMouseUp = function(event) {};

    MyStage.prototype.onMouseMove = function(event) {
      var delta, mouse;
      mouse = new num.Num2(event.stageX, event.stageY);
      if (this._dragStartPosition) {
        delta = num.Num2.subtract(mouse, this._dragStartPosition);
      }
      if (event.nativeEvent.which === 2) {
        this.offset = this._dragStartOffset.add(delta);
      }
      return this.update();
    };

    MyStage.prototype.addChild = function(child) {
      MyStage.__super__.addChild.call(this, child);
      return child.on('changedAsync', this._updateSelf);
    };

    MyStage.prototype.removeChild = function(child) {
      MyStage.__super__.removeChild.call(this, child);
      return child.off('changedAsync', this._updateSelf);
    };

    return MyStage;

  })(createjs.Stage);

}).call(this);
