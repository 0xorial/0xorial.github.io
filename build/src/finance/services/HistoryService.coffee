app.service 'HistoryService', ->

  currentStateWithHistory = null

  resetState = ->
    currentStateWithHistory = {
      state: {}
      history: []
    }

  return {

    setInitialState: (state) ->
      if currentStateWithHistory.history.length
        throw new Error()
      currentStateWithHistory.state = state

    acceptNewState: (state) ->
      delta = jsondiffpatch.diff(state, currentStateWithHistory.state)
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
      currentState = currentStateWithHistory.state
      while currentIndex > index
        currentState = jsondiffpatch.reverse(currentState, currentStateWithHistory.history[currentIndex])

      return currentState

    getData: ->
      return currentStateWithHistory

    setData: (state) ->
      currentStateWithHistory = state
      return
    }
