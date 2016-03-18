app.service 'JsonSerializationService', ->

  serializeStateToJson = (data) ->
    ctx = new SerializationContext()

    accounts = data.accounts
    payments = data.payments

    accounts = accounts.map (a) -> a.toJson(ctx)
    payments = payments.map (p) ->
      json = p.toJson(ctx)
      if !json.id
        json.id = p.id
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
      account = Account.fromJson(a, ctx)
      account.id = a.id
      accounts.push account

    payments = []
    for p in root.payments
      payment = null
      switch p.type
        when 'SimplePayment'
          payment = SimplePayment.fromJson(p, ctx)
        when 'BorrowPayment'
          payment = BorrowPayment.fromJson(p, ctx)
        when 'PeriodicPayment'
          payment = PeriodicPayment.fromJson(p, ctx)
        when 'TaxableIncomePayment'
          payment = TaxableIncomePayment.fromJson(p, ctx)
        else
          throw new Error()
      payment.id = p.id
      payments.push payment

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
