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

exports = window

_.mixin {
  augmentDate: (o, datePropertyName) ->
    Object.defineProperty o, _.camelCase(datePropertyName + '_js'),
      get: -> @[datePropertyName].toDate()
      set: (value) -> @[datePropertyName] = moment(value)

  augmentDatesDeep: (o) ->
    _.traverse o, (val, key, obj) ->
      if moment.isMoment(val)
        _.augmentDate(o, key)

  traverse: (obj, cb) ->
    myIsObject = (o) ->
      return !_.isFunction(o) and _.isObject(o)

    _.forIn obj, (val, key) ->
      cb(val, key, obj)
      if _.isArray(val)
        val.forEach (el) ->
          if myIsObject(el)
            _.traverse(el, cb)
      else if myIsObject(obj[key])
        _.traverse(obj[key], cb)
  }

console.realWarn = console.warn;
console.warn = (message) ->
  if (message.indexOf("ARIA") == -1)
    console.realWarn.apply(console, arguments);


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