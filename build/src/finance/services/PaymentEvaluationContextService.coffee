app.service 'FormulaEvaluationService', (DataService) ->

  class Context
    constructor: () ->

    findPayment: (id) ->
      payments = DataService.getAllPayments()
      return _.find(payments, {id: id})

    getFormulaValue: (name) ->
      context = this
      return eval(DataService.getValues()[name])

  class Evaluator
    constructor: ->
      @context = new Context()

    evaluateAmount: (amount) ->
      if _.isNumber(amount)
        return amount
      if _.isString(amount)
        p = @context.findPayment
        v = @context.getFormulaValue
        amount = eval(amount)
      return amount

    evaluateFormula: (formula) ->
      if _.isNumber(amount)
        return amount
      if _.isString(amount)
        p = @context.findPayment
        v = @context.getFormulaValue
        amount = eval(amount)
      return amount

  return {
    getEvaluator: ->
      return new Evaluator()
  }
