# responsible for loading raw data, populating raw data and tracking raw data changes. raw data is string
app.service 'DocumentDataService', (
  DataService,
  HistoryService,
  JsonSerializationService,
  UndoRedoService) ->

  initializeFromHistoryService = ->
    jsonState = HistoryService.peekState()
    state = JsonSerializationService.deserialize(jsonState)
    DataService.setPayments(state.payments)
    DataService.setAccounts(state.accounts)
    DataService.setValues(state.values)
    DataService.notifyChanged()
    UndoRedoService.reset()

  acceptNewHistoryState = ->
    state = {
      payments: DataService.getAllPayments()
      accounts: DataService.getAccounts()
      values: DataService.getValues()
    }
    jsonState = JsonSerializationService.serialize(state)
    HistoryService.acceptNewState(jsonState)

  setRawData = (jsonData) ->
    data = jsonData
    HistoryService.setStateWithHistory(data)
    initializeFromHistoryService()

  return {

    acceptNewHistoryState: ->
      acceptNewHistoryState()

    # for new file and demo data
    setData: (payments, accounts, values) ->
      jsonState = JsonSerializationService.serialize({
        payments: demoPayments,
        accounts: demoAccounts,
        values: demoValues})
      HistoryService.setState(jsonState)
      initializeFromHistoryService()

    getRawData: () ->
      currentData = HistoryService.getStateWithHistory()
      return JSON.stringify(currentData, null, '  ')

    setRawData: (stringData) ->
      json = JSON.parse(stringData)
      setRawData(json)

    getIndex: ->
      accounts = DataService.getAccounts()
      payments = DataService.getAllPayments()
      accountsText = accounts.map((a) -> a.name).join(',')
      paymentsText = payments.map((p) -> p.description).join(',')
      return accountsText + ',' + paymentsText

    getThumbnail: ->
      return DataService.getThumbnail()
  }
