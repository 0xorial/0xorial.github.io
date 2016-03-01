(function() {
  var exports, findLineCircleIntersections, lerp, segmentContainsPoint;

  if (!exports) {
    exports = {};
  }

  _globals.num = exports;

  lerp = function(a, b, t) {
    return a + (b - a) * t;
  };

  findLineCircleIntersections = function(point1, point2, cx, cy, radius) {
    var A, B, C, det, dx, dy, intersection1, intersection2, t;
    dx = point2.x - point1.x;
    dy = point2.y - point1.y;
    A = dx * dx + dy * dy;
    B = 2 * (dx * (point1.x - cx) + dy * (point1.y - cy));
    C = (point1.x - cx) * (point1.x - cx) + (point1.y - cy) * (point1.y - cy) - radius * radius;
    det = B * B - 4 * A * C;
    if ((A <= 0.0000001) || (det < 0)) {
      return [];
    } else if (exports.epsilonEquals(det, 0)) {
      t = -B / (2 * A);
      return [new exports.Num2(point1.x + t * dx, point1.y + t * dy)];
    } else {
      t = (-B + Math.sqrt(det)) / (2 * A);
      intersection1 = new exports.Num2(point1.x + t * dx, point1.y + t * dy);
      t = (-B - Math.sqrt(det)) / (2 * A);
      intersection2 = new exports.Num2(point1.x + t * dx, point1.y + t * dy);
      return [intersection1, intersection2];
    }
  };

  segmentContainsPoint = function(point1, point2, point) {
    var dpx, dpy, tx, ty;
    dpx = point2.x - point1.x;
    dpy = point2.y - point1.y;
    tx = (point.x - point1.x) / dpx;
    ty = (point.y - point1.y) / dpy;
    if (exports.epsilonEquals(dpx, 0)) {
      return exports.epsilonEquals(point.x, point1.x) && ty >= -0.1 && ty <= 1.1;
    }
    if (exports.epsilonEquals(dpy, 0)) {
      return exports.epsilonEquals(point.y, point1.y) && tx >= -0.1 && tx <= 1.1;
    }
    if (exports.epsilonEquals(tx, ty) && tx >= -0.1 && tx <= 1.1) {
      return true;
    }
    return false;
  };

  exports.findLineSegmentCircleIntersections = function(point1, point2, cx, cy, radius) {
    var lineIntersections;
    lineIntersections = findLineCircleIntersections(point1, point2, cx, cy, radius);
    return lineIntersections.filter(function(i) {
      return segmentContainsPoint(point1, point2, i);
    });
  };

  exports.Num2 = (function() {
    function Num2(x, y) {
      this.x = x;
      this.y = y;
      if (this.x.x !== void 0) {
        this.y = this.x.y;
        this.x = this.x.x;
      } else if (this.y === void 0) {
        this.y = this.x;
      }
    }

    Num2.vectorFromPoints = function(start, end) {
      return exports.Num2.subtract(end, start);
    };

    Num2.prototype.toString = function() {
      return 'x ' + this.x + '; y:' + this.y;
    };

    Num2.prototype.add = function(x, y) {
      if (x.x !== void 0) {
        y = x.y;
        x = x.x;
      }
      if (y === void 0) {
        y = x;
      }
      return new exports.Num2(this.x + x, this.y + y);
    };

    Num2.prototype.addThis = function(x, y) {
      if (x.x !== void 0) {
        y = x.y;
        x = x.x;
      }
      if (y === void 0) {
        y = x;
      }
      this.x += x;
      return this.y += y;
    };

    Num2.prototype.multiply = function(x) {
      return new exports.Num2(this.x * x, this.y * x);
    };

    Num2.prototype.subtract = function(x, y) {
      if (x.x !== void 0) {
        y = x.y;
        x = x.x;
      }
      if (y === void 0) {
        y = x;
      }
      return new exports.Num2(this.x - x, this.y - y);
    };

    Num2.prototype.distanceTo = function(x, y) {
      return Math.sqrt(this.distanceToSquared(x, y));
    };

    Num2.prototype.distanceToSquared = function(x, y) {
      var delta;
      if (x.x !== void 0) {
        y = x.y;
        x = x.x;
      }
      if (y === void 0) {
        y = x;
      }
      delta = this.subtract(x, y);
      return delta.x * delta.x + delta.y * delta.y;
    };

    Num2.prototype.length = function() {
      return this.distanceTo(0, 0);
    };

    Num2.prototype.lerpTo = function(x, y, t) {
      if (x.x !== void 0) {
        t = y;
        y = x.y;
        x = x.x;
      }
      return new exports.Num2(lerp(this.x, x, t), lerp(this.y, y, t));
    };

    Num2.prototype.dot = function(other) {
      return this.x * other.x + this.y * other.y;
    };

    Num2.prototype.cross = function(other) {
      return this.x * other.y - this.y * other.x;
    };

    Num2.prototype.angleTo = function(other) {
      return Math.atan2(other.y, other.x) - Math.atan2(this.y, this.x);
    };

    Num2.prototype.angleToDeg = function(other) {
      return this.angleTo(other) * 180 / Math.PI;
    };

    Num2.prototype.rotateAround = function(center, angle) {
      var c, cx, cy, p, px, py, s, xnew, ynew;
      c = Math.cos(angle);
      s = Math.sin(angle);
      cx = center.x;
      cy = center.y;
      p = this;
      px = p.x - cx;
      py = p.y - cy;
      xnew = px * c - py * s;
      ynew = px * s + py * c;
      return new exports.Num2(xnew + cx, ynew + cy);
    };

    Num2.prototype.rotateAroundDeg = function(center, angleDeg) {
      var angle;
      angle = angleDeg * Math.PI / 180;
      return this.rotateAround(center, angle);
    };

    Num2.prototype.clone = function() {
      return new exports.Num2(this.x, this.y);
    };

    Num2.prototype.epsilonEquals = function(other, epsilon) {
      if (epsilon == null) {
        epsilon = 0.01;
      }
      return exports.epsilonEquals(this.x, other.x, epsilon) && exports.epsilonEquals(this.y, other.y, epsilon);
    };

    Num2.subtract = function(num1, num2) {
      return new exports.Num2(num1.x - num2.x, num1.y - num2.y);
    };

    return Num2;

  })();

  exports.Num2.zero = new exports.Num2(0, 0);

  Victor.fromPoints = function(start, end) {
    return Victor.fromObject(end).subtract(Victor.fromObject(start));
  };

  Victor.prototype.multiplyScalar = function(scalar) {
    this.x *= scalar;
    this.y *= scalar;
    return this;
  };

  exports.epsilonEquals = function(x, y, epsilon) {
    if (epsilon == null) {
      epsilon = 0.01;
    }
    return Math.abs(x - y) < epsilon;
  };

}).call(this);
