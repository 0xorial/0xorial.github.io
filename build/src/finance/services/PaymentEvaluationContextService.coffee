app.service 'FormulaEvaluationService', (DataService) ->

  class Context
    constructor: (@evaluator) ->

    findPayment: (id) ->
      payments = DataService.getAllPayments()
      payment = _.find(payments, {id: id})
      amount = @evaluator.evaluateAmount(payment.amount)
      return {a: amount}

    getFormulaValue: (name) ->
      value = DataService.getValues()[name]
      amount = @evaluator.evaluateFormula(value)
      return {a: amount}

  class Evaluator
    constructor: ->
      @context = new Context(@)

    evaluateAmount: (amount) ->
      if _.isNumber(amount)
        return amount
      if _.isString(amount)
        p = => @context.findPayment(arguments[0])
        v = => @context.getFormulaValue(arguments[0])
        result = eval(amount)
      return result

    evaluateFormula: (formula) ->
      if _.isNumber(formula)
        return formula
      if _.isString(formula)
        p = => @context.findPayment(arguments[0])
        v = => @context.getFormulaValue(arguments[0])
        amount = eval(formula)
      return amount

  return {
    getEvaluator: ->
      return new Evaluator()
  }
