(function() {
  var exports,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  exports = window;

  exports.Account = (function() {
    function Account(currency, name, color) {
      this.currency = currency;
      this.name = name;
      this.color = color;
    }

    Account.prototype.toJson = function(context) {
      if (!this.id) {
        throw new Error();
      }
      return {
        id: context.registerObjectWithId(this, this.id),
        currency: this.currency,
        name: this.name,
        color: this.color
      };
    };

    Account.fromJson = function(json, context) {
      var r;
      r = new exports.Account(json.currency, json.name, json.color);
      context.registerObjectWithId(json.id, r);
      return r;
    };

    return Account;

  })();

  exports.AccountsState = (function() {
    function AccountsState(accounts, balances) {
      this.accounts = accounts;
      this.balances = balances;
      if (!this.balances) {
        this.balances = this.accounts.map(function() {
          return 0;
        });
      }
    }

    AccountsState.prototype.execute = function(account, amount) {
      var a, b, found, index, newBalances, _i, _len, _ref;
      newBalances = [];
      found = false;
      _ref = this.balances;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        b = _ref[index];
        a = this.accounts[index];
        if (!found && a === account) {
          found = true;
          newBalances.push(b + amount);
        } else {
          newBalances.push(b);
        }
      }
      return new exports.AccountsState(this.accounts, newBalances);
    };

    AccountsState.prototype.getAccountBalance = function(account) {
      var index;
      index = _.indexOf(this.accounts, account);
      if (index === -1) {
        throw new Error('account not found');
      }
      return this.balances[index];
    };

    return AccountsState;

  })();

  exports.Transaction = (function() {
    function Transaction(date, amount, account, description, payment, id) {
      this.date = date;
      this.amount = amount;
      this.account = account;
      this.description = description;
      this.payment = payment;
      this.id = id;
    }

    return Transaction;

  })();

  exports.Payment = (function() {
    function Payment() {}

    Payment.prototype.getTransactions = function(context) {
      throw new Error('abstract method');
    };

    Payment.prototype.clone = function() {
      var c;
      c = new this.constructor();
      this.assignTo(c);
      return c;
    };

    return Payment;

  })();

  exports.SimplePayment = (function(_super) {
    __extends(SimplePayment, _super);

    function SimplePayment(account, date, amount, description, isDeductible, deductiblePercentage) {
      this.account = account;
      this.date = date;
      this.amount = amount;
      this.description = description;
      this.isDeductible = isDeductible;
      this.deductiblePercentage = deductiblePercentage;
      if (!this.date) {
        this.date = moment();
      }
      this.deductiblePercentage |= 0;
    }

    SimplePayment.prototype.getTransactions = function(context) {
      return context.transaction(this.date, -this.amount, this.account, this.description, this);
    };

    SimplePayment.prototype.assignTo = function(to) {
      return _.assign(to, this);
    };

    SimplePayment.prototype.toJson = function(context) {
      return {
        type: 'SimplePayment',
        date: this.date.valueOf(),
        amount: this.amount,
        accountId: context.getObjectId(this.account),
        description: this.description,
        isDeductible: this.isDeductible,
        deductiblePercentage: this.deductiblePercentage
      };
    };

    SimplePayment.fromJson = function(json, context) {
      return new exports.SimplePayment(context.resolveObject(json.accountId), moment(json.date), json.amount, json.description, json.isDeductible, json.deductiblePercentage);
    };

    return SimplePayment;

  })(exports.Payment);

  exports.PeriodicPayment = (function(_super) {
    __extends(PeriodicPayment, _super);

    function PeriodicPayment(account, startDate, endDate, period, amount, description) {
      this.account = account;
      this.startDate = startDate;
      this.endDate = endDate;
      this.period = period;
      this.amount = amount;
      this.description = description;
      if (!this.startDate) {
        this.startDate = moment();
      }
      if (!this.endDate) {
        this.endDate = moment();
      }
    }

    PeriodicPayment.prototype.getTransactions = function(context) {
      var date, _results;
      date = this.startDate.clone();
      _results = [];
      while (date.isBefore(this.endDate)) {
        context.transaction(date.clone(), -this.amount, this.account, this.description, this);
        _results.push(date.add(this.period.quantity, this.period.units));
      }
      return _results;
    };

    PeriodicPayment.prototype.assignTo = function(to) {
      return _.assign(to, this);
    };

    PeriodicPayment.prototype.toJson = function(context) {
      return {
        type: 'PeriodicPayment',
        accountId: context.getObjectId(this.account),
        startDate: this.startDate.valueOf(),
        endDate: this.endDate.valueOf(),
        period: this.period,
        amount: this.amount,
        description: this.description
      };
    };

    PeriodicPayment.fromJson = function(json, context) {
      return new exports.PeriodicPayment(context.resolveObject(json.accountId), moment(json.startDate), moment(json.endDate), json.period, json.amount, json.description);
    };

    return PeriodicPayment;

  })(exports.Payment);

  exports.BorrowPayment = (function(_super) {
    __extends(BorrowPayment, _super);

    function BorrowPayment(account, date, returnDate, amount, description, interest) {
      this.account = account;
      this.date = date;
      this.returnDate = returnDate;
      this.amount = amount;
      this.description = description;
      this.interest = interest;
      if (!this.interest) {
        this.interest = 0;
      }
      if (!this.date) {
        this.date = moment();
      }
      if (!this.returnDate) {
        this.returnDate = moment();
      }
    }

    BorrowPayment.prototype.getTransactions = function(context) {
      var days, diff, fraction, interest, returnAmount;
      context.transaction(this.date, this.amount, this.account, 'borrow ' + this.description, this);
      diff = this.returnDate.diff(this.date);
      days = moment.duration(diff).asDays();
      fraction = days / 365;
      interest = fraction * this.interest;
      returnAmount = this.amount * (-1) * (1 + interest);
      return context.transaction(this.returnDate, returnAmount, this.account, 'return ' + this.description, this);
    };

    BorrowPayment.prototype.assignTo = function(to) {
      return _.assign(to, this);
    };

    BorrowPayment.prototype.toJson = function(context) {
      return {
        type: 'BorrowPayment',
        accountId: context.getObjectId(this.account),
        date: this.date.valueOf(),
        returnDate: this.returnDate.valueOf(),
        amount: this.amount,
        description: this.description,
        interest: this.interest
      };
    };

    BorrowPayment.fromJson = function(json, context) {
      return new exports.BorrowPayment(context.resolveObject(json.accountId), moment(json.date), moment(json.returnDate), json.amount, json.description, json.interest);
    };

    return BorrowPayment;

  })(exports.Payment);

  exports.BeTaxSystem = (function() {
    function BeTaxSystem() {}

    BeTaxSystem.prototype.calculate = function(data, allPayments, context) {
      var account, allowance, byYear, deductibleExpensesByYear, deductibleNonVat, deductiblePayments, deductibleVat, getDeductibaleNonVat, getDeductibaleVat, isTaxableIncome, lastDayOfYear, payments, personalIncome, personalIncomeTaxToPay, personalTaxPayDate, personalTaxRate, social, socialTaxToPay, taxablePersonalIncome, totalYearIncome, vatToPay, vatYearIncome, year, yearExpenses, yearPayments, _results;
      isTaxableIncome = function(p) {
        return p instanceof exports.TaxableIncomePayment;
      };
      payments = allPayments.filter(isTaxableIncome);
      if (payments.length > 0) {
        account = _.first(payments).account;
      }
      deductiblePayments = allPayments.filter(function(p) {
        return p.isDeductible;
      });
      deductibleExpensesByYear = _.groupBy(deductiblePayments, function(p) {
        return p.date.year();
      });
      byYear = _.groupBy(payments, function(p) {
        return p.params.paymentDate.year();
      });
      getDeductibaleVat = function(p) {
        return (p.deductiblePercentage || 1) * p.amount * (p.vatPercentage || 0);
      };
      getDeductibaleNonVat = function(p) {
        return (p.deductiblePercentage || 1) * p.amount * (1 - (p.vatPercentage || 0));
      };
      _results = [];
      for (year in byYear) {
        yearPayments = byYear[year];
        yearExpenses = deductibleExpensesByYear[year] || [];
        totalYearIncome = _.sumBy0(yearPayments, function(p) {
          return p.amount * (1 - (p.params.vatPercentage || 0));
        });
        vatYearIncome = _.sumBy0(yearPayments, function(p) {
          return p.amount * p.params.vatPercentage;
        });
        deductibleVat = _.sumBy0(yearExpenses, getDeductibaleVat);
        deductibleNonVat = _.sumBy0(yearExpenses, getDeductibaleNonVat);
        totalYearIncome = totalYearIncome + deductibleVat;
        totalYearIncome = totalYearIncome - deductibleNonVat;
        vatToPay = vatYearIncome - deductibleVat;
        if (vatToPay < 0) {
          vatToPay = 0;
        }
        lastDayOfYear = moment({
          year: year
        }).add(1, 'year').subtract(1, 'days');
        context.transaction(lastDayOfYear, -vatToPay, account, 'vat payment', void 0);
        social = 0.22;
        socialTaxToPay = totalYearIncome * social;
        context.transaction(lastDayOfYear, -socialTaxToPay, account, 'social tax', void 0);
        allowance = 7090;
        personalIncome = totalYearIncome - socialTaxToPay;
        taxablePersonalIncome = personalIncome - allowance;
        if (taxablePersonalIncome < 0) {
          taxablePersonalIncome = 0;
        }
        personalTaxRate = 0;
        if (taxablePersonalIncome < 8680) {
          personalTaxRate = 0.25;
        } else if (taxablePersonalIncome < 12360) {
          personalTaxRate = 0.3;
        } else if (taxablePersonalIncome < 20600) {
          personalTaxRate = 0.4;
        } else if (taxablePersonalIncome < 37750) {
          personalTaxRate = 0.45;
        } else {
          personalTaxRate = 0.5;
        }
        personalTaxPayDate = moment({
          year: year + 1,
          month: 6
        });
        personalIncomeTaxToPay = taxablePersonalIncome * personalTaxRate;
        _results.push(context.transaction(lastDayOfYear, -personalIncomeTaxToPay, account, 'personal income tax', void 0));
      }
      return _results;
    };

    return BeTaxSystem;

  })();

  exports.TaxableIncomePayment = (function(_super) {
    __extends(TaxableIncomePayment, _super);

    function TaxableIncomePayment(account, amount, params) {
      this.account = account;
      this.amount = amount;
      this.params = params;
      if (!this.params) {
        this.params = {
          vatPercentage: 0.21,
          paymentDate: moment(),
          deducibleExpenses: []
        };
      }
    }

    TaxableIncomePayment.prototype.getTransactions = function(context) {
      return context.transaction(this.params.paymentDate, this.amount, this.account, 'salary', this);
    };

    TaxableIncomePayment.prototype.assignTo = function(to) {
      _.assign(to, this);
      to.params = {};
      return _.assign(to.params, this.params);
    };

    TaxableIncomePayment.prototype.toJson = function(context) {
      var params;
      params = _.clone(this.params);
      params.paymentDate = params.paymentDate.valueOf();
      return {
        type: 'TaxableIncomePayment',
        accountId: context.getObjectId(this.account),
        params: params,
        amount: this.amount
      };
    };

    TaxableIncomePayment.fromJson = function(json, context) {
      var params;
      params = _.clone(json.params);
      params.paymentDate = moment(params.paymentDate);
      return new exports.TaxableIncomePayment(context.resolveObject(json.accountId), json.amount, params);
    };

    return TaxableIncomePayment;

  })(exports.Payment);

  exports.sortTransactions = function(transactions) {
    return transactions.sort(function(a, b) {
      if (a.date.isSame(b.date)) {
        if (a.id === b.id) {
          return 0;
        }
        if (a.id < b.id) {
          return -1;
        }
        return 1;
      }
      if (a.date.isBefore(b.date)) {
        return -1;
      }
      return 1;
    });
  };

  exports.SimulationContext = (function() {
    function SimulationContext(accounts) {
      this.accounts = accounts;
      this.nextTransactionId = 0;
      this.transactions = [];
      this.currentAccountsState = new exports.AccountsState(this.accounts);
    }

    SimulationContext.prototype.transaction = function(date, amount, account, description, payment) {
      var t;
      t = new exports.Transaction(date, amount, account, description, payment, this.nextTransactionId++);
      return this.transactions.push(t);
    };

    SimulationContext.prototype.executeTransactions = function() {
      var newState, t, _i, _len, _ref, _results;
      exports.sortTransactions(this.transactions);
      _ref = this.transactions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        newState = this.currentAccountsState.execute(t.account, t.amount);
        t.accountState = newState;
        _results.push(this.currentAccountsState = newState);
      }
      return _results;
    };

    return SimulationContext;

  })();

}).call(this);
