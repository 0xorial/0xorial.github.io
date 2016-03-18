exports = window

class exports.Transaction
  constructor: (@date, @amount, @account, @description, @payment, @id) ->
    if isNaN(@amount) or @amount == undefined or @amount == null
      throw new Error() 
