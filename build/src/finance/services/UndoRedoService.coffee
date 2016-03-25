app.service 'UndoRedoService', ($rootScope, HistoryService, JsonSerializationService, DataService)->

  undoPointer = -1
  possibleRedos = 0

  applyStateAtIndex = (index, hint) ->
    jsonState = HistoryService.peekState(index)
    state = JsonSerializationService.deserialize(jsonState)
    DataService.setState(state, hint)
    HistoryService.acceptNewState(jsonState)

  return {
    reset: ->
      undoPointer = HistoryService.getStateHistoryCount() - 1
      possibleRedos = 0

    canUndo: ->
      return undoPointer > 0

    undo: ->
      undoPointer--
      possibleRedos++
      applyStateAtIndex(undoPointer, 'undo')

    canRedo: ->
      return possibleRedos > 0

    redo: ->
      undoPointer++
      possibleRedos--
      applyStateAtIndex(undoPointer, 'redo')
  }
