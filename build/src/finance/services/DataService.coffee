dataContainer = {
  accounts: []
  payments: []
}

app.service 'DataService', ($rootScope)->
  return {
    getAccounts: ->
      return dataContainer.accounts
    setAccounts: (value) ->
      dataContainer.accounts = value
    deleteAccount: (account) ->
      _.remove(dataContainer.accounts, account)
      $rootScope.$broadcast 'dataChanged'

    addAccount: (account) ->
      dataContainer.accounts.push(account)
      $rootScope.$broadcast 'dataChanged'

    getPayments: ->
      return dataContainer.payments
    setPayments: (value) ->
      dataContainer.payments = value

    addPayment: (payment) ->
      dataContainer.payments.push payment
      $rootScope.$broadcast 'dataChanged'

    deletePayment: (payment) ->
      _.remove(dataContainer.payments, payment)
      $rootScope.$broadcast 'dataChanged'

    notifyChanged: ->
      $rootScope.$broadcast 'dataChanged'
    }
