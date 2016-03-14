exports = window

payments = window

payments.Payment.prototype.assignTo = ->
  throw new Error('abstract method')

payments.SimplePayment.prototype.assignTo = (to) ->
  _.assign(to, @)

payments.BorrowPayment.prototype.assignTo = (to) ->
  _.assign(to, @)

payments.PeriodicPayment.prototype.assignTo = (to) ->
  _.assign(to, @)

payments.TaxableIncomePayment.prototype.assignTo = (to) ->
  _.assign(to, @)
  to.params = {}
  _.assign(to.params, @params)
