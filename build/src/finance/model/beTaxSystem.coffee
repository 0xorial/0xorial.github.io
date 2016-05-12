exports = window

class exports.BeTaxSystem

  getPersonalIncomeTaxAmount: (personalIncome, allowance) ->
    # allowance = 7090
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
    personalIncomeTaxToPay = taxablePersonalIncome * personalTaxRate
    return { amount: personalIncomeTaxToPay, rate: personalTaxRate, taxableAmount: taxablePersonalIncome }

  getVatPayments: (incomePayments) ->
    r = []
    for p in incomePayments
      for links in p.links
        tags = link.tags.split ' '
        if _.any(tags, 'vat')
          r.push link
    return r

  getSocialTaxPayments: (incomePayments) ->
    r = []
    for p in incomePayments
      for links in p.links
        tags = link.tags.split ' '
        if _.any(tags, 'social')
          r.push link
    return r

  getVatPaymentDate: (incomeDate) ->
    quarter = incomeDate.quarter()
    year = incomeDate.year()
    quarter++
    if quarter = 5
      quarter = 1
      year++
    result = incomeDate.clone()
    result.year(year)
    result.quarter(quarter)
    result.date(21)
    return result

  getSocialTaxPaymentDate: (incomeDate) ->
    quarter = incomeDate.quarter()
    year = incomeDate.year()
    quarter++
    if quarter = 5
      quarter = 1
      year++
    result = incomeDate.clone()
    result.year(year)
    result.quarter(quarter)
    result.date(1)
    return result



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

      deductibleExpensesByQuarter = _.groupBy(deductibleExpensesByYear, (p) -> p.date.quarter())
      byQuarter = _.groupBy(yearPayments, (p) -> p.params.paymentDate.quarter())
      totalYearPersonalIncome = 0

      for quarter of byQuarter
        quarterIncomes = byQuarter[quarter]
        quarterExpenses = deductibleExpensesByQuarter[quarter] or []

        quarterVatTaxPayments = @getVatPayments(quarterIncomes)
        quarterSocialTaxPayments = @getSocialTaxPayments(quarterIncomes)

        totalQuarterIncome = _.sumBy0(quarterIncomes, (p) -> p.getAmount(evaluationContext))
        vatQuarterIncome = _.sumBy0(quarterIncomes, (p) -> p.getAmount(evaluationContext) * p.params.vatPercentage)

        deductibleVat = _.sumBy0(quarterExpenses, getDeductibaleVat)
        deductibleNonVat = _.sumBy0(quarterExpenses, getDeductibaleNonVat)

        totalVatToPay = Math.max(0, vatQuarterIncome - deductibleVat)
        vatPayed = _.sumBy0(quarterVatTaxPayments, (p) -> p.amount)
        vatLeftToPay = totalVatToPay - vatPayed
        if vatLeftToPay > 0
          date = @getVatPaymentDate(quarterIncomes[0].params.paymentDate)
          context.transaction(date, -vatLeftToPay, account, 'vat payment', undefined)

        afterVatQuarterIncome = totalQuarterIncome - totalVatToPay

        totalSocialTaxToPay = afterVatQuarterIncome * 0.22
        socialTaxPayed = _.sumBy0(quarterSocialTaxPayments, (p) -> p.amount)
        socialTaxLeftToPay = totalSocialTaxToPay - socialTaxPayed
        if socialTaxLeftToPay > 0
          date = @getSocialTaxPaymentDate(quarterIncomes[0].params.paymentDate)
          context.transaction(date, -socialTaxLeftToPay, account, 'social tax', undefined)

        quarterPersonalIncome = afterVatQuarterIncome - totalSocialTaxToPay
        totalYearPersonalIncome += quarterPersonalIncome

      personalIncomeTax = @getPersonalIncomeTaxAmount(totalYearPersonalIncome, 7090)
      personalTaxPayDate = moment({year: year + 1, month: 6})
      t = context.transaction(personalTaxPayDate, -personalIncomeTax.amount, account, 'personal income tax', undefined)
      t.additionalInfo = 'Total income was: ' + totalYearPersonalIncome + '. Taxable personal income was: ' + personalIncomeTax.taxableAmount + '. Tax rate applied was: ' + personalIncomeTax.rate
