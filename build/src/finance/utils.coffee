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

  assertNumber: (n) ->
    if !_.isNumber(n) or isNaN(n)
      throw new Error()

  sumBy0: (c, i) ->
    r = _.sum(c.map(i))
    r = 0 if !r
    return r

  augmentDate: (o, datePropertyName) ->
    propertyName = _.camelCase(datePropertyName + '_js')
    if o.hasOwnProperty propertyName
      return
    Object.defineProperty o, propertyName,
      get: -> @[datePropertyName].toDate()
      set: (value) -> @[datePropertyName] = moment(value)

  augmentDatesDeep: (o) ->
    _.traverse o, (val, key, obj) ->
      if moment.isMoment(val)
        _.augmentDate(obj, key)


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

  except: (c, predicate) ->
    iteratee = _.iteratee(predicate)
    if _.isFunction(predicate)
      return _.filter(c, (p) -> !predicate(p))
    else
      return _.filter(c, (p) -> p != predicate)

  merge: (options) ->
    {src, dst, make, equals, assign} = options
    for i in src
      existing = _.find(dst, (e) -> equals(i, e))
      if !existing
        existing = make()
        dst.push(existing)
      assign(existing, i)

    toRemove = _.differenceWith(dst, src, (x, y) -> equals(y, x))
    for i in toRemove
      _.remove(dst, i)
  }

console.realWarn = console.warn;
console.warn = (message) ->
  if message and _.isFunction(message.indexOf) and message.indexOf("ARIA") != -1
    return
  console.realWarn.apply(console, arguments);


class exports.SerializationContext
  constructor: ->
    @objects = {}

  # registerObject: (object) ->
  #   @objects.push(object)
  #   return @objects.length - 1
  #
  registerObjectWithId: (id, object) ->
    @objects[id] = object

  getObjectId: (object) ->
    if !object.id
      throw new Error()
    return object.id

  resolveObject: (id) ->
    return @objects[id]

numeral.languageData().delimiters.thousands = ' '
