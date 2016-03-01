(function() {
  var iced, __iced_k, __iced_k_noop,
    __slice = [].slice;

  iced = {
    Deferrals: (function() {
      function _Class(_arg) {
        this.continuation = _arg;
        this.count = 1;
        this.ret = null;
      }

      _Class.prototype._fulfill = function() {
        if (!--this.count) {
          return this.continuation(this.ret);
        }
      };

      _Class.prototype.defer = function(defer_params) {
        ++this.count;
        return (function(_this) {
          return function() {
            var inner_params, _ref;
            inner_params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            if (defer_params != null) {
              if ((_ref = defer_params.assign_fn) != null) {
                _ref.apply(null, inner_params);
              }
            }
            return _this._fulfill();
          };
        })(this);
      };

      return _Class;

    })(),
    findDeferral: function() {
      return null;
    },
    trampoline: function(_fn) {
      return _fn();
    }
  };
  __iced_k = __iced_k_noop = function() {};

  app.controller('SerializationCtrl', function($scope, $timeout, $rootScope, DataService, SavingService, $state, $stateParams, $location) {
    var progress, undoPointer, undoStack;
    undoStack = [];
    undoPointer = -1;
    $scope.canUndo = false;
    $scope.canRedo = false;
    $scope.isLoading = true;
    $scope.status = 'Loading...';
    progress = function(m) {
      return $timeout(function() {
        return $scope.$apply(function() {
          return $scope.status = m;
        });
      });
    };
    SavingService.loadFile($stateParams.documentPath, (function(error, name) {
      return $timeout(function() {
        return $scope.$apply(function() {
          $scope.driveFileName = name;
          $scope.isLoading = false;
          if (!error) {
            return $scope.status = 'Ready';
          }
        });
      });
    }), progress);
    $scope.loadData = function() {};
    $scope.saveData = function() {};
    $scope.saveDrive = function() {
      var file, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      __iced_deferrals = new iced.Deferrals(__iced_k, {
        parent: ___iced_passed_deferral,
        filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\controllers\\SerializationCtrl.coffee",
        funcname: "saveDrive"
      });
      SavingService.saveDrive($stateParams.documentPath, __iced_deferrals.defer({
        assign_fn: (function(_this) {
          return function() {
            return function() {
              return file = arguments[0];
            };
          };
        })(this)(),
        lineno: 29
      }), progress);
      __iced_deferrals._fulfill();
    };
    $scope.saveDriveNew = function() {
      var file, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (!$scope.driveFileName) {
        progress('Enter file name.');
      }
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\controllers\\SerializationCtrl.coffee",
            funcname: "saveDriveNew"
          });
          SavingService.saveNewDrive($scope.driveFileName, __iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return file = arguments[0];
              };
            })(),
            lineno: 34
          }), progress);
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          return $state.go('.', {
            documentPath: 'drive:' + file.id
          }, {
            notify: false
          });
        };
      })(this));
    };
    $scope.canUndo = function() {
      return undoPointer > 1;
    };
    $scope.canRedo = function() {
      return undoPointer < undoStack.length - 1;
    };
    $scope.undo = function() {
      return $scope.serializedData = undoStack[--undoPointer];
    };
    $scope.redo = function() {
      return $scope.serializedData = undoStack[++undoPointer];
    };
    $scope.$on('dataChanged', function() {
      return $scope.serializedData = SavingService.saveJson();
    });
    $scope.$watch('serializedData', function() {
      var currentStackData;
      currentStackData = undoStack[undoPointer];
      if (currentStackData !== $scope.serializedData && $scope.serializedData) {
        undoStack.splice(undoPointer + 1);
        undoStack.push($scope.serializedData);
        undoPointer++;
      }
      if ($scope.serializedData) {
        return SavingService.loadJson($scope.serializedData);
      }
    });
    return $scope.copy = function() {
      return new Clipboard('#copy', {
        text: function() {
          return $scope.serializedData;
        }
      });
    };
  });

}).call(this);
