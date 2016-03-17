app.service 'PaymentEvaluationContextService', (DataService) ->
  return {
    getContext: -> {
      p: (id) ->
        payments = DataService.getAllPayments()
        return _.find(payments, {id: id})
    }
  }
