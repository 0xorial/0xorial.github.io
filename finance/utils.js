(function() {
  var exports;

  Function.prototype.property = function(prop, desc) {
    return Object.defineProperty(this.prototype, prop, desc);
  };

  Function.prototype.augmentDate = function(datePropertyName) {
    return this.property(_.camelCase('js_' + datePropertyName), {
      get: function() {
        return this[datePropertyName].toDate();
      },
      set: function(value) {
        return this[datePropertyName] = moment(value);
      }
    });
  };

  Function.prototype.augmentDateDeep = function(propertyName, getSetDate) {
    return this.property(propertyName, {
      get: function() {
        return getSetDate.get.call(this).toDate();
      },
      set: function(value) {
        return getSetDate.set.call(this, moment(value));
      }
    });
  };

  exports = window;

  _.mixin({
    sumBy0: function(c, i) {
      var r;
      r = _.sum(c.map(i));
      if (!r) {
        r = 0;
      }
      return r;
    },
    augmentDate: function(o, datePropertyName) {
      return Object.defineProperty(o, _.camelCase(datePropertyName + '_js'), {
        get: function() {
          return this[datePropertyName].toDate();
        },
        set: function(value) {
          return this[datePropertyName] = moment(value);
        }
      });
    },
    augmentDatesDeep: function(o) {
      return _.traverse(o, function(val, key, obj) {
        obj.$$dateAugmented = true;
        if (moment.isMoment(val)) {
          return _.augmentDate(obj, key);
        }
      });
    },
    traverse: function(obj, cb) {
      var myIsObject;
      myIsObject = function(o) {
        return !_.isFunction(o) && _.isObject(o);
      };
      return _.forIn(obj, function(val, key) {
        cb(val, key, obj);
        if (_.isArray(val)) {
          return val.forEach(function(el) {
            if (myIsObject(el)) {
              return _.traverse(el, cb);
            }
          });
        } else if (myIsObject(obj[key])) {
          return _.traverse(obj[key], cb);
        }
      });
    },
    except: function(c, predicate) {
      var iteratee;
      iteratee = _.iteratee(predicate);
      if (_.isFunction(predicate)) {
        return _.filter(c, function(p) {
          return !predicate(p);
        });
      } else {
        return _.filter(c, function(p) {
          return p !== predicate;
        });
      }
    },
    merge: function(options) {
      var assign, dst, equals, existing, i, make, src, toRemove, _i, _j, _len, _len1, _results;
      src = options.src, dst = options.dst, make = options.make, equals = options.equals, assign = options.assign;
      for (_i = 0, _len = src.length; _i < _len; _i++) {
        i = src[_i];
        existing = _.find(dst, function(e) {
          return equals(i, e);
        });
        if (!existing) {
          existing = make();
          dst.push(existing);
        }
        assign(existing, i);
      }
      toRemove = _.differenceWith(dst, src, function(x, y) {
        return equals(y, x);
      });
      _results = [];
      for (_j = 0, _len1 = toRemove.length; _j < _len1; _j++) {
        i = toRemove[_j];
        _results.push(_.remove(dst, i));
      }
      return _results;
    }
  });

  console.realWarn = console.warn;

  console.warn = function(message) {
    if (message.indexOf("ARIA") === -1) {
      return console.realWarn.apply(console, arguments);
    }
  };

  exports.SerializationContext = (function() {
    function SerializationContext() {
      this.objects = {};
    }

    SerializationContext.prototype.registerObjectWithId = function(id, object) {
      return this.objects[id] = object;
    };

    SerializationContext.prototype.getObjectId = function(object) {
      if (!object.id) {
        throw new Error();
      }
      return object.id;
    };

    SerializationContext.prototype.resolveObject = function(id) {
      return this.objects[id];
    };

    return SerializationContext;

  })();

}).call(this);
