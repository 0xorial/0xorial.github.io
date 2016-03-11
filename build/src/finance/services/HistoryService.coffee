app.service 'HistoryService', ->

  currentStateWithHistory = null

  resetState = ->
    currentStateWithHistory = {
      state: {}
      history: []
    }

  return {

    acceptNewState: (state) ->
      delta = new jsondiffpatch.DiffPatcher().diff(currentStateWithHistory.state, state)
      if delta
        currentStateWithHistory.history.push({
          delta: delta
          })
        currentStateWithHistory.state = state

    resetState: ->
      resetState()

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

    getData: ->
      return currentStateWithHistory

    setData: (state) ->
      currentStateWithHistory = state
      return
    }
