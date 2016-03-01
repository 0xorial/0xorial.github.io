(function() {
  var CLIENT_ID, SCOPES, iced, __iced_k, __iced_k_noop,
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

  CLIENT_ID = '738883605733-b6bc7deeulg034sncifk1upknib3b0n0.apps.googleusercontent.com';

  SCOPES = ['https://www.googleapis.com/auth/drive.metadata.readonly', 'https://www.googleapis.com/auth/drive.file'];

  app.service('GoogleDriveSaveService', function() {
    var authAndLoadApi, doUpdateFile, downloadFile, ensureInitCompleted, init, initFinished, initStarted, initWaiters, insertFile, loadClient, progress, waitForInit;
    loadClient = function(cb) {
      if (g_gapiClientLoaded) {
        return cb();
      } else {
        return window.g_gapiClientLoadedCb = function() {
          cb();
          return window.g_gapiClientLoadedCb = null;
        };
      }
    };
    authAndLoadApi = function(cb) {
      var authResult, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      progress('Loading client...');
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
          });
          loadClient(__iced_deferrals.defer({
            lineno: 18
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          progress('Authorizing...');
          (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
            });
            gapi.auth.authorize({
              'client_id': CLIENT_ID,
              'scope': SCOPES.join(' '),
              'immediate': true
            }, __iced_deferrals.defer({
              assign_fn: (function() {
                return function() {
                  return authResult = arguments[0];
                };
              })(),
              lineno: 24
            }));
            __iced_deferrals._fulfill();
          })(function() {
            (function(__iced_k) {
              if (authResult && !authResult.error) {
                progress('Loading drive API...');
                (function(__iced_k) {
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral,
                    filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
                  });
                  gapi.client.load('drive', 'v2', __iced_deferrals.defer({
                    lineno: 27
                  }));
                  __iced_deferrals._fulfill();
                })(function() {
                  return __iced_k(cb());
                });
              } else {
                progress('Authorize error: ' + authResult.error);
                console.log('could not authorise');
                return __iced_k(console.log(authResult));
              }
            })(function() {});
          });
        };
      })(this));
    };
    initWaiters = [];
    initFinished = false;
    waitForInit = function(listener) {
      return initWaiters.push(listener);
    };
    initStarted = false;
    init = function() {
      var waiter, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      if (initStarted) {
        return;
      }
      initStarted = true;
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
          });
          authAndLoadApi(__iced_deferrals.defer({
            lineno: 45
          }));
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          var _i, _len, _results;
          initFinished = true;
          _results = [];
          for (_i = 0, _len = initWaiters.length; _i < _len; _i++) {
            waiter = initWaiters[_i];
            _results.push(waiter.done());
          }
          return _results;
        };
      })(this));
    };
    progress = function(m) {
      var waiter, _i, _len;
      for (_i = 0, _len = initWaiters.length; _i < _len; _i++) {
        waiter = initWaiters[_i];
        waiter.progress(m);
      }
    };
    ensureInitCompleted = function(loadListener) {
      if (initFinished) {
        return loadListener.done();
      } else {
        init();
        return waitForInit(loadListener);
      }
    };
    insertFile = function(name, fileData, callback) {
      var base64Data, boundary, close_delim, contentType, delimiter, metadata, multipartRequestBody, request;
      boundary = '-------314159265358979323846';
      delimiter = '\r\n--' + boundary + '\r\n';
      close_delim = '\r\n--' + boundary + '--';
      contentType = 'application/json';
      metadata = {
        'title': name,
        'mimeType': contentType
      };
      base64Data = btoa(fileData);
      multipartRequestBody = delimiter + 'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter + 'Content-Type: ' + contentType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim;
      request = gapi.client.request({
        'path': '/upload/drive/v2/files',
        'method': 'POST',
        'params': {
          'uploadType': 'multipart'
        },
        'headers': {
          'Content-Type': 'multipart/mixed; boundary="' + boundary + '"'
        },
        'body': multipartRequestBody
      });
      if (!callback) {
        callback = function(file) {
          console.log(file);
        };
      }
      request.execute(callback);
    };
    doUpdateFile = function(id, fileData, callback) {
      var base64Data, boundary, close_delim, contentType, delimiter, metadata, multipartRequestBody, request;
      boundary = '-------314159265358979323846';
      delimiter = '\r\n--' + boundary + '\r\n';
      close_delim = '\r\n--' + boundary + '--';
      contentType = 'application/json';
      metadata = {};
      base64Data = btoa(fileData);
      multipartRequestBody = delimiter + 'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter + 'Content-Type: ' + contentType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim;
      request = gapi.client.request({
        'path': '/upload/drive/v2/files/' + id,
        'method': 'PUT',
        'params': {
          'uploadType': 'multipart',
          'alt': 'json'
        },
        'headers': {
          'Content-Type': 'multipart/mixed; boundary="' + boundary + '"'
        },
        'body': multipartRequestBody
      });
      request.then(function(response) {
        return callback();
      }, function(reason) {
        console.log(reason);
        return callback(reason);
      });
    };
    downloadFile = function(id, callback, progress) {
      var accessToken, file, request, result, url, xhr, ___iced_passed_deferral, __iced_deferrals, __iced_k;
      __iced_k = __iced_k_noop;
      ___iced_passed_deferral = iced.findDeferral(arguments);
      request = gapi.client.drive.files.get({
        'fileId': id
      });
      progress('Opening file...');
      (function(_this) {
        return (function(__iced_k) {
          __iced_deferrals = new iced.Deferrals(__iced_k, {
            parent: ___iced_passed_deferral,
            filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
          });
          request.then(__iced_deferrals.defer({
            assign_fn: (function() {
              return function() {
                return result = arguments[0];
              };
            })(),
            lineno: 116
          }), function(e) {
            console.log(e);
            return callback(e);
          });
          __iced_deferrals._fulfill();
        });
      })(this)((function(_this) {
        return function() {
          file = result.result;
          url = file.downloadUrl;
          accessToken = gapi.auth.getToken().access_token;
          xhr = new XMLHttpRequest;
          xhr.open('GET', url);
          xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
          progress('Downloading file...');
          xhr.onload = function() {
            callback(null, file, xhr.responseText);
          };
          xhr.onerror = function(e) {
            console.log(arguments);
            callback(e);
          };
          return xhr.send();
        };
      })(this));
    };
    return {
      loadFile: function(id, callback, progress) {
        var data, error, file, ___iced_passed_deferral, __iced_deferrals, __iced_k;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        (function(_this) {
          return (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
            });
            ensureInitCompleted({
              done: __iced_deferrals.defer({
                lineno: 137
              }),
              progress: progress
            });
            __iced_deferrals._fulfill();
          });
        })(this)((function(_this) {
          return function() {
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
              });
              downloadFile(id, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    error = arguments[0];
                    file = arguments[1];
                    return data = arguments[2];
                  };
                })(),
                lineno: 138
              }), progress);
              __iced_deferrals._fulfill();
            })(function() {
              return callback(error, file, data);
            });
          };
        })(this));
      },
      newFile: function(name, data, done, progress) {
        var arg, ___iced_passed_deferral, __iced_deferrals, __iced_k;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        (function(_this) {
          return (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
            });
            ensureInitCompleted({
              done: __iced_deferrals.defer({
                lineno: 142
              }),
              progress: progress
            });
            __iced_deferrals._fulfill();
          });
        })(this)((function(_this) {
          return function() {
            progress('Saving file...');
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
              });
              insertFile(name, data, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return arg = arguments[0];
                  };
                })(),
                lineno: 144
              }));
              __iced_deferrals._fulfill();
            })(function() {
              console.log(arg);
              progress('File saved.');
              return done(arg);
            });
          };
        })(this));
      },
      updateFile: function(id, data, done, progress) {
        var error, ___iced_passed_deferral, __iced_deferrals, __iced_k;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        (function(_this) {
          return (function(__iced_k) {
            __iced_deferrals = new iced.Deferrals(__iced_k, {
              parent: ___iced_passed_deferral,
              filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
            });
            ensureInitCompleted({
              done: __iced_deferrals.defer({
                lineno: 150
              }),
              progress: progress
            });
            __iced_deferrals._fulfill();
          });
        })(this)((function(_this) {
          return function() {
            progress('Saving file...');
            (function(__iced_k) {
              __iced_deferrals = new iced.Deferrals(__iced_k, {
                parent: ___iced_passed_deferral,
                filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\GoogleDriveSaveService.coffee"
              });
              doUpdateFile(id, data, __iced_deferrals.defer({
                assign_fn: (function() {
                  return function() {
                    return error = arguments[0];
                  };
                })(),
                lineno: 152
              }));
              __iced_deferrals._fulfill();
            })(function() {
              if (!error) {
                progress('File saved.');
              }
              return done();
            });
          };
        })(this));
      }
    };
  });

}).call(this);
