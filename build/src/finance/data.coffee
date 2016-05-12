exports = window;

Types = {
  Simple: 'simple'
  Borrow: 'borrow'
  SimpleExpense: 'simpleExpense'
  TaxableIncome: 'taxableIncome'
  PeriodicPayment: 'periodicPayment'
}

account1 = new Account('EUR', 'cash', 'green', 11)
account2 = new Account('USD', 'cash USD', 'yellow', 12)
account3 = new Account('EUR', 'bank corporate', 'orange', 13)
account4 = new Account('EUR', 'bank 2', 'blue', 14)

eur = (a) -> new CurrencyAmount('EUR', a)

allAccountsData = [
  account1, account2, account3, account4,
  # account1, account2, account3, account4,
  # account1, account2, account3, account4,
  # account1, account2, account3, account4,
  # account1, account2, account3, account4,
  # account1, account2, account3, account4,
]

constants = {
  'bikePrice': 1050
  'rate': 'v("bikePrice").a / 10'
}

transactions = [
  {"id": 1, "type": Types.Borrow, "date": "3/12/2015", "returnDate": "11/12/2015", "amount": 'p(5).a', "description": "Tom", "account": account1},
  {"id": 4, "type": Types.Simple, "date": "1/12/2015", "amount": 1000, "description": "initial money", "account": account1},
  {"id": 5, "type": Types.SimpleExpense, "date": "3/12/2015", "amount": 'v("bikePrice").a', "description": "bought bike", "account": account1}
  {"id": 9, "type": Types.SimpleExpense, "date": "15/12/2015", "amount": '100', "description": "paid some tax", "account": account1, tags: ['vat']}
  {"id": 6, "type": Types.PeriodicPayment, "startDate": "14/1/2015", "endDate": "25/2/2016", "period":{quantity: 1, units: "months"}, "amount": -100, "description": "alimony", "account": account1}
  {"id": 7, "type": Types.TaxableIncome, "date": "10/12/2015", "amount": 'v("rate").a * 22', "description": "payment for hard work", "account": account3, "links": [9]}
  {"id": 8, "type": Types.Borrow, "date": "4/12/2015", "returnDate": "11/12/2015",  "amount": 150, "description": "Wim", "account": account1},
]

deserializePayment = (p) ->
  date = moment(p.date, "D-M-YYYY")
  m = (s) ->
    moment(s, "D-M-YYYY")
  account = p.account
  switch p.type
    when Types.Simple then return new SimplePayment(account, date, p.amount, p.description)
    when Types.Borrow then return new BorrowPayment(account, date, m(p.returnDate), p.amount, p.description)
    when Types.PeriodicPayment then return new PeriodicPayment(account, m(p.startDate),  m(p.endDate), p.period, p.amount, p.description)
    when Types.SimpleExpense then return new SimplePayment(account, date, p.amount, p.description)
    when Types.TaxableIncome
      params =
        vatPercentage: 0.21
        description: p.description
        paymentDate: date
      return new TaxableIncomePayment(account, p.amount, '', params)

deserializeTempPayment = (p) ->
  payment = deserializePayment(p)
  return {
    payment: payment
    json: p
  }


tempPayments = transactions.map (t) ->
  r = deserializeTempPayment(t)
  r.payment.id = t.id
  return r

for p in tempPayments
  p.payment.tags = p.json.tags || []
  links = p.json.links || []
  p.links = []
  for linkId in links
    payment = _.find(tempPayments, (t) -> t.json.id == linkId)
    if !payment
      throw new Error()
    p.links.push payment

exports.demoPayments = tempPayments.map (p) -> p.payment

console.log demoPayments

exports.demoAccounts = allAccountsData

exports.demoValues = constants
