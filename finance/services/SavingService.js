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

  app.service('SavingService', function(DataService, GoogleDriveSaveService) {
    var deserialize, serialize;
    serialize = function() {
      var accounts, ctx, payments, root;
      ctx = new SerializationContext();
      accounts = DataService.getAccounts();
      payments = DataService.getAllPayments();
      accounts = accounts.map(function(a) {
        return a.toJson(ctx);
      });
      payments = payments.map(function(p) {
        var json;
        json = p.toJson(ctx);
        if (!json.id) {
          json.id = p.id;
        }
        return json;
      });
      root = {
        accounts: accounts,
        payments: payments
      };
      return JSON.stringify(root, null, '  ');
    };
    deserialize = function(jsonString) {
      var a, account, accounts, ctx, p, payment, payments, root, _i, _j, _len, _len1, _ref, _ref1;
      root = JSON.parse(jsonString);
      ctx = new SerializationContext();
      accounts = [];
      _ref = root.accounts;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        account = Account.fromJson(a, ctx);
        account.id = a.id;
        accounts.push(account);
      }
      payments = [];
      _ref1 = root.payments;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        p = _ref1[_j];
        payment = null;
        switch (p.type) {
          case 'SimplePayment':
            payment = SimplePayment.fromJson(p, ctx);
            break;
          case 'BorrowPayment':
            payment = BorrowPayment.fromJson(p, ctx);
            break;
          case 'PeriodicPayment':
            payment = PeriodicPayment.fromJson(p, ctx);
            break;
          case 'TaxableIncomePayment':
            payment = TaxableIncomePayment.fromJson(p, ctx);
            break;
          default:
            throw new Error();
        }
        payment.id = p.id;
        payments.push(payment);
      }
      DataService.setAccounts(accounts);
      DataService.setPayments(payments);
      DataService.notifyChanged();
    };
    return {
      loadJson: function(json) {
        return deserialize(json);
      },
      saveJson: function() {
        return serialize();
      },
      saveDrive: function(documentPath, done, progress) {
        var data, id;
        if (!_.startsWith(documentPath, 'drive:')) {
          throw new Erorr();
        }
        id = documentPath.substring(6);
        data = serialize();
        return GoogleDriveSaveService.updateFile(id, data, done, progress);
      },
      saveNewDrive: function(name, done, progress) {
        var data;
        data = serialize();
        return GoogleDriveSaveService.newFile(name, data, done, progress);
      },
      loadFile: function(path, cb, progress) {
        var accounts, data, error, file, payments, ___iced_passed_deferral, __iced_deferrals, __iced_k;
        __iced_k = __iced_k_noop;
        ___iced_passed_deferral = iced.findDeferral(arguments);
        accounts = null;
        payments = null;
        if (path === 'demo') {
          accounts = demoAccounts;
          payments = demoPayments;
          DataService.setAccounts(accounts);
          DataService.setPayments(payments);
          DataService.notifyChanged();
          return __iced_k(cb(null, 'demo'));
        } else {
          (function(_this) {
            return (function(__iced_k) {
              if (_.startsWith(path, 'drive:')) {
                (function(__iced_k) {
                  __iced_deferrals = new iced.Deferrals(__iced_k, {
                    parent: ___iced_passed_deferral,
                    filename: "C:\\Users\\ironic\\Documents\\0xorial.github.io\\build\\src\\finance\\services\\SavingService.coffee"
                  });
                  GoogleDriveSaveService.loadFile(path.substring(6), __iced_deferrals.defer({
                    assign_fn: (function() {
                      return function() {
                        error = arguments[0];
                        file = arguments[1];
                        return data = arguments[2];
                      };
                    })(),
                    lineno: 77
                  }), progress);
                  __iced_deferrals._fulfill();
                })(function() {
                  return __iced_k(!error ? (deserialize(data), console.log(file), cb(error, file.title)) : (progress('Error loading file.'), cb(error)));
                });
              } else {
                throw new Error('unknown path');
                return __iced_k();
              }
            });
          })(this)(__iced_k);
        }
      },
      documentChanged: function(path) {}
    };
  });

}).call(this);
