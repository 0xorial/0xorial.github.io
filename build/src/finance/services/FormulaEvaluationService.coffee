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
      if !value
        console.warn('value not found: ' + name)
        return {a: 0}
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
        try
          result = eval(amount)
        catch e
          result = 0
          console.warn e
      _.assertNumber(result)
      return result

    evaluateFormula: (formula) ->
      if _.isNumber(formula)
        return formula
      if _.isString(formula)
        p = => @context.findPayment(arguments[0])
        v = => @context.getFormulaValue(arguments[0])
        try
          amount = eval(formula)
        catch e
          amount = 0
          console.warn e
      _.assertNumber(amount)
      return amount

  return {
    getEvaluator: ->
      return new Evaluator()
  }
