class SerializationContext
  constructor: ->
    @objects = {}

  registerObjectWithId: (id, object) ->
    @objects[id] = object

  getObjectId: (object) ->
    if !object.id
      throw new Error()
    return object.id

  resolveObject: (id) ->
    return @objects[id]


app.service 'JsonSerializationService', (DataService) ->

  serializeStateToJson = (data) ->
    accounts = data.accounts
    payments = data.payments

    accounts = accounts.map (a) ->
      json = a.toJson()
      if !a.id
        throw new Error('no id')
      json.id = a.id
      return json
    payments = payments.map (p) ->
      json = p.toJson()
      json.id = p.id
      if !p.id
        throw new Error('no id')
      if p instanceof SimplePayment
        json.type = 'SimplePayment'
      else if p instanceof BorrowPayment
        json.type = 'BorrowPayment'
      else if p instanceof PeriodicPayment
        json.type = 'PeriodicPayment'
      else if p instanceof TaxableIncomePayment
        json.type = 'TaxableIncomePayment'
      else
        throw new Error()

      return json

    root = {
      accounts: accounts
      payments: payments
      values: data.values
    }
    return root

  deserializeStateFromJson = (root) ->
    ctx = new SerializationContext()
    accounts = []
    for a in root.accounts
      account = Account.fromJson(a)
      account.id = a.id
      ctx.registerObjectWithId(account.id, account)
      accounts.push account

    payments = []
    for p in root.payments
      payment = null
      switch p.type
        when 'SimplePayment'
          payment = new SimplePayment()
        when 'BorrowPayment'
          payment = new BorrowPayment()
        when 'PeriodicPayment'
          payment = new PeriodicPayment()
        when 'TaxableIncomePayment'
          payment = new TaxableIncomePayment()
        else
          throw new Error()
      payment.id = p.id
      ctx.registerObjectWithId(payment.id, payment)
      payments.push {payment: payment, json: p}

    for p in payments
      p.payment.fromJson(p.json, ctx)

    payments = payments.map (p) -> p.payment

    return {
      accounts: accounts
      payments: payments
      values: root.values ? {}
    }


  return {
    # object to return and accept:
    # {accounts: array of accounts
    #  payments: array of payments}

    serialize: (data) ->
      return serializeStateToJson(data)

    deserialize: (jsonObject) ->
      return deserializeStateFromJson(jsonObject)
  }
