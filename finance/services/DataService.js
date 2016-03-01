(function() {
  var dataContainer;

  dataContainer = {
    accounts: [],
    payments: [],
    nextId: 1,
    usedIds: {}
  };

  app.service('DataService', function($rootScope) {
    var ensureId, ensureIds, takeIdFor;
    takeIdFor = function(o) {
      while (dataContainer.usedIds[dataContainer.nextId]) {
        dataContainer.nextId++;
      }
      o.id = dataContainer.nextId;
      dataContainer.usedIds[o.id] = o;
      dataContainer.nextId++;
    };
    ensureId = function(o) {
      if (!o.id) {
        return takeIdFor(o);
      }
    };
    ensureIds = function() {
      var a, p, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results;
      dataContainer.usedIds = {};
      _ref = dataContainer.accounts;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        if (a.id) {
          dataContainer.usedIds[a.id] = a;
        }
      }
      _ref1 = dataContainer.payments;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        p = _ref1[_j];
        if (p.id) {
          dataContainer.usedIds[p.id] = p;
        }
      }
      _ref2 = dataContainer.accounts;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        a = _ref2[_k];
        if (!a.id) {
          takeIdFor(a);
        }
      }
      _ref3 = dataContainer.payments;
      _results = [];
      for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
        p = _ref3[_l];
        if (!p.id) {
          _results.push(takeIdFor(p));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
    return {
      getAccounts: function() {
        return dataContainer.accounts;
      },
      setAccounts: function(value) {
        dataContainer.accounts = value;
        return ensureIds();
      },
      deleteAccount: function(account) {
        _.remove(dataContainer.accounts, account);
        ensureIds();
        return $rootScope.$broadcast('dataChanged');
      },
      addAccount: function(account) {
        dataContainer.accounts.push(account);
        ensureIds();
        return $rootScope.$broadcast('dataChanged');
      },
      getAllPayments: function() {
        return dataContainer.payments;
      },
      getUnmutedPayments: function() {
        return dataContainer.payments.filter(function(p) {
          return !p.isMuted;
        });
      },
      setPayments: function(value) {
        dataContainer.payments = value;
        return ensureIds();
      },
      addPayment: function(payment) {
        dataContainer.payments.push(payment);
        ensureIds();
        return $rootScope.$broadcast('dataChanged');
      },
      deletePayment: function(payment) {
        _.remove(dataContainer.payments, payment);
        ensureIds();
        return $rootScope.$broadcast('dataChanged');
      },
      notifyChanged: function() {
        return $rootScope.$broadcast('dataChanged');
      }
    };
  });

}).call(this);
