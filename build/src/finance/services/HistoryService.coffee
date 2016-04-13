app.service 'HistoryService', ($rootScope) ->

  currentStateWithHistory = null

  resetState = ->
    currentStateWithHistory = {
      state: {}
      history: []
    }

  acceptNewState = (state, description) ->
    delta = new jsondiffpatch.DiffPatcher({
      objectHash: (o, i) ->
        if o.id == undefined
          throw new Error('no id on object: ' + JSON.stringify(o))
        o.id
      }).diff(currentStateWithHistory.state, state)
    if delta
      currentStateWithHistory.history.push({
        delta: delta
        description: description
        })
      currentStateWithHistory.state = state

  return {

    acceptNewState: (state, description) ->
      acceptNewState(state, description)

    setState: (state) ->
      resetState()
      acceptNewState(state)

    peekState: (index) ->
      if index == undefined
        index = currentStateWithHistory.history.length - 1

      currentIndex = currentStateWithHistory.history.length - 1
      currentState = JSON.parse(JSON.stringify(currentStateWithHistory.state))
      while currentIndex > index
        new jsondiffpatch.DiffPatcher().unpatch(currentState, currentStateWithHistory.history[currentIndex].delta)
        currentIndex--

      return currentState

    getStateHistoryCount: ->
      return currentStateWithHistory.history.length

    getStateWithHistory: ->
      return currentStateWithHistory


    setStateWithHistory: (state) ->
      currentStateWithHistory = state
      return
    }
