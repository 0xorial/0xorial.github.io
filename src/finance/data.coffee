exports = window;

Types = {
  Simple: 'simple'
  Borrow: 'borrow'
  SimpleExpense: 'simpleExpense'
  TaxableIncome: 'taxableIncome'
  PeriodicPayment: 'periodicPayment'
}

account1 = new Account('EUR', 'cash', 'green')
account2 = new Account('USD', 'cash USD', 'yellow')
account3 = new Account('EUR', 'bank corporate', 'orange')
account4 = new Account('EUR', 'bank 2', 'blue')

eur = (a) -> new CurrencyAmount('EUR', a)
staticAccount = (a) -> new StaticAccountSelector(a)

allAccountsData = [account1, account2, account3, account4]

allAccounts = new FirstSuitingSelector(allAccountsData)

transactions = [
  {"id": 1, "type": Types.Simple, "date": "1/12/2015", "amount": 1000, "description": "initial money", "account": staticAccount(account1)},
  {"id": 2, "type": Types.Borrow, "date": "3/12/2015", "returnDate": "11/12/2015", "amount": 100, "description": "Tom", "account": staticAccount(account1)},
  {"id": 7, "type": Types.SimpleExpense, "date": "3/12/2015", "amount": 1050, "description": "bought bike", "account": allAccounts}
  {"id": 3, "type": Types.Borrow, "date": "4/12/2015", "returnDate": "11/12/2015",  "amount": 150, "description": "Wim", "account": staticAccount(account1)},
  {"id": 5, "type": Types.TaxableIncome, "date": "10/12/2015", "amount": 1000, "description": "payment for hard work", "account": staticAccount(account3)}
]

deserializePayment = (p) ->
  date = moment(p.date, "D-M-YYYY")
  accountSelector = p.account
  switch p.type
    when Types.Simple then return new SimplePayment(accountSelector, date, eur(p.amount), p.description)
    when Types.Borrow then return new BorrowPayment(accountSelector, date, moment(p.returnDate, "D-M-YYYY"), eur(p.amount), p.description)
    when Types.SimpleExpense then return new SimplePayment(accountSelector, date, eur(-p.amount), p.description)
    when Types.TaxableIncome
      params =
        description: p.description
        earnedAt: date
        paymentDate: date
      return new TaxableIncomePayment(accountSelector, eur(p.amount), params)


exports.payments = transactions.map (t) -> deserializePayment(t)
exports.allAccountsData = allAccountsData
