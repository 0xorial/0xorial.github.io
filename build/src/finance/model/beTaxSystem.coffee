exports = window

class exports.BeTaxSystem
  calculate: (data, allPayments, context, evaluationContext) ->
    isTaxableIncome = (p) -> p instanceof exports.TaxableIncomePayment
    payments = allPayments.filter(isTaxableIncome)
    if payments.length > 0
      account = _.first(payments).account
    deductiblePayments = allPayments.filter((p) -> p.isDeductible)
    deductibleExpensesByYear = _.groupBy(deductiblePayments, (p) -> p.date.year())
    byYear = _.groupBy(payments, (p) -> p.params.paymentDate.year())
    getDeductibaleVat = (p) -> (p.deductiblePercentage or 1)*p.amount*(p.vatPercentage or 0)
    getDeductibaleNonVat = (p) -> (p.deductiblePercentage or 1)*p.amount*(1 - (p.vatPercentage or 0))
    for year of byYear
      yearPayments = byYear[year]
      yearExpenses = deductibleExpensesByYear[year] or []

      #amount without VAT
      totalYearIncome = _.sumBy0(yearPayments, (p) -> p.getAmount(evaluationContext) * (1 - (p.params.vatPercentage or 0)))
      vatYearIncome = _.sumBy0(yearPayments, (p) -> p.getAmount(evaluationContext) * p.params.vatPercentage)

      deductibleVat = _.sumBy0(yearExpenses, getDeductibaleVat)
      deductibleNonVat = _.sumBy0(yearExpenses, getDeductibaleNonVat)

      # todo: does vat reduction increase personal income?...
      # currently assume it does
      totalYearIncome = totalYearIncome + deductibleVat

      totalYearIncome = totalYearIncome - deductibleNonVat

      vatToPay = vatYearIncome - deductibleVat
      vatToPay = 0 if vatToPay < 0

      # todo: when to pay vat?
      lastDayOfYear = moment({year: year}).add(1, 'year').subtract(1, 'days')
      context.transaction(lastDayOfYear, -vatToPay, account, 'vat payment', undefined)

      social = 0.22
      socialTaxToPay = totalYearIncome * social
      context.transaction(lastDayOfYear, -socialTaxToPay, account, 'social tax', undefined)

      allowance = 7090
      personalIncome = totalYearIncome - socialTaxToPay
      taxablePersonalIncome = personalIncome - allowance
      if taxablePersonalIncome < 0
        taxablePersonalIncome = 0
      personalTaxRate = 0
      if taxablePersonalIncome < 8680
        personalTaxRate = 0.25
      else if taxablePersonalIncome < 12360
        personalTaxRate = 0.3
      else if taxablePersonalIncome < 20600
        personalTaxRate = 0.4
      else if taxablePersonalIncome < 37750
        personalTaxRate = 0.45
      else
        personalTaxRate = 0.5

      personalTaxPayDate = moment({year: year + 1, month: 6})
      personalIncomeTaxToPay = taxablePersonalIncome * personalTaxRate
      t = context.transaction(lastDayOfYear, -personalIncomeTaxToPay, account, 'personal income tax', undefined)
      t.additionalInfo = 'Total income was: ' + totalYearIncome + '. Taxable personal income was: ' + taxablePersonalIncome + '. Tax rate applied was: ' + personalTaxRate
