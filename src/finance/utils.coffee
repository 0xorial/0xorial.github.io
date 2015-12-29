Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

Function::augmentDate = (datePropertyName) ->
  @property _.camelCase('js_' + datePropertyName),
    get: -> @[datePropertyName].toDate()
    set: (value) -> @[datePropertyName] = moment(value)

Function::augmentDateDeep = (propertyName, getSetDate) ->
  @property propertyName,
    get: -> getSetDate.get.call(@).toDate()
    set: (value) -> getSetDate.set.call(@, moment(value))

console.realWarn = console.warn;
console.warn = (message) ->
  if (message.indexOf("ARIA") == -1)
    console.realWarn.apply(console, arguments);

exports = window

class exports.SerializationContext
  constructor: ->
    @objects = []

  registerObject: (object) ->
    @objects.push(object)
    return @objects.length - 1

  registerObjectWithId: (id, object) ->
    @objects[id] = object

  getObjectId: (object) ->
    for o,id in @objects
      if o == object
        return id
    throw new Error()

  resolveObject: (id) ->
    return @objects[id]
