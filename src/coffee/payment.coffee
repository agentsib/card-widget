QJ = require './qj'


defaultFormat = /(\d{1,4})/g

#cards = [
#  {
#      type: 'amex'
#      pattern: /^3[47]/
#      format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/
#      length: [15]
#      cvcLength: [4]
#      luhn: true
#  }
#  {
#      type: 'dankort',
#      pattern: /^5019/,
#      format: defaultFormat,
#      length: [16],
#      cvcLength: [3],
#      luhn: true
#  }
#  {
#      type: 'dinersclub'
#      pattern: /^(36|38|30[0-5])/
#      format: /(\d{1,4})(\d{1,6})?(\d{1,4})?/
#      length: [14]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'discover'
#      pattern: /^(6011|65|64[4-9]|622)/
#      format: defaultFormat
#      length: [16]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'jcb'
#      pattern: /^35/
#      format: defaultFormat
#      length: [16]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'laser'
#      pattern: /^(6706|6771|6709)/
#      format: defaultFormat
#      length: [16..19]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'maestro'
#      pattern: /^(5018|5020|5038|6304|6703|6708|6759|676[1-3])/
#      format: defaultFormat
#      length: [12..19]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'mastercard'
#      pattern: /^(5[1-5]|677189)|^(222[1-9]|2[3-6]\d{2}|27[0-1]\d|2720)/
#      format: defaultFormat
#      length: [16]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'unionpay'
#      pattern: /^62/
#      format: defaultFormat
#      length: [16..19]
#      cvcLength: [3]
#      luhn: false
#  }
#  {
#      type: 'visaelectron',
#      pattern: /^4(026|17500|405|508|844|91[37])/,
#      format: defaultFormat,
#      length: [16],
#      cvcLength: [3],
#      luhn: true
#  }
#  {
#      type: 'elo'
#      pattern: /^(4011|438935|45(1416|76|7393)|50(4175|6699|67|90[4-7])|63(6297|6368))/,
#      format: defaultFormat
#      length: [16]
#      cvcLength: [3]
#      luhn: true
#  }
#  {
#      type: 'visa'
#      pattern: /^4/
#      format: defaultFormat
#      length: [13, 16, 19]
#      cvcLength: [3]
#      luhn: true
#  }
#]

cards = [
  {
    type: 'mir'
    pattern: /^(220[0-4])/
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'maestro'
  # pattern: /^(5018|5020|5038|6304|6703|6708|6759|676[1-3])/
    pattern: /^(50|5[6-9]|6[0-9])/
    format: defaultFormat
    length: [12..19]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'mastercard'
   # pattern: /^(5[1-5]|677189)|^(222[1-9]|2[3-6]\d{2}|27[0-1]\d|2720)/
    pattern: /^(5[1-5]|222[1-9]|22[3-9][0-9]|2[3-6][0-9][0-9]|27[0-1][0-9]|2720)/
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'visaelectron'
    pattern: /^4(026|17500|405|508|844|91[37])/
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'visa'
    pattern: /^4/
    format: defaultFormat
    length: [13..16]
    cvcLength: [3]
    luhn: true
  }
]

cardFromNumber = (num) ->
  num = (num + '').replace(/\D/g, '')
  return card for card in cards when card.pattern.test(num)

cardFromType = (type) ->
  return card for card in cards when card.type is type

luhnCheck = (num) ->
  odd = true
  sum = 0

  digits = (num + '').split('').reverse()

  for digit in digits
    digit = parseInt(digit, 10)
    digit *= 2 if (odd = !odd)
    digit -= 9 if digit > 9
    sum += digit

  sum % 10 == 0

hasTextSelected = (target) ->
  try
    # If some text is selected
    return true if target.selectionStart? and
      target.selectionStart isnt target.selectionEnd

    # If some text is selected in IE
    if document?.selection?.createRange?
      return true if document.selection.createRange().text
  catch e

  false

# Private

# Format Card Number

reFormatCardNumber = (e) ->
  setTimeout =>
    target = e.target
    value   = QJ.val(target)
    value = value.replace /\D/g, ''
    value   = Payment.fns.formatCardNumber(value)
    QJ.val(target, value)
    QJ.trigger(target, 'change')
    QJ.trigger(target, 'keyup')
    null

formatCardNumber = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  target = e.target
  value   = QJ.val(target)
  card    = cardFromNumber(value + digit)
  length  = (value.replace(/\D/g, '') + digit).length

  upperLength = 16
  upperLength = card.length[card.length.length - 1] if card
  return if length >= upperLength

  # Return if focus isn't at the end of the text
  return if hasTextSelected(target)

  if card && card.type is 'amex'
    # Amex cards are formatted differently
    re = /^(\d{4}|\d{4}\s\d{6})$/
  else
    re = /(?:^|\s)(\d{4})$/

  # If '4242' + 4
  if re.test(value)
    e.preventDefault()
    QJ.val(target, value + ' ' + digit)
    QJ.trigger(target, 'change')

  # If '424' + 2
  else if re.test(value + digit)
    e.preventDefault()
    QJ.val(target, value + digit + ' ')
    QJ.trigger(target, 'change')

formatBackCardNumber = (e) ->
  target = e.target
  value   = QJ.val(target)

  return if e.meta

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if hasTextSelected(target)

  # Remove the trailing space
  if /\d\s$/.test(value)
    e.preventDefault()
    QJ.val(target, value.replace(/\d\s$/, ''))
  else if /\s\d?$/.test(value)
    e.preventDefault()
    QJ.val(target, value.replace(/\s\d?$/, ''))

# Format Expiry

formatExpiry = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  target = e.target
  val     = QJ.val(target) + digit

  if /^\d$/.test(val) and val not in ['0', '1']
    e.preventDefault()
    QJ.val(target, "0#{val} / ")

  else if /^\d\d$/.test(val)
    e.preventDefault()
    QJ.val(target, "#{val} / ")

formatMonthExpiry = (e) ->
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  target = e.target
  val     = QJ.val(target) + digit

  if /^\d$/.test(val) and val not in ['0', '1']
    e.preventDefault()
    QJ.val(target, "0#{val}")

  else if /^\d\d$/.test(val)
    e.preventDefault()
    QJ.val(target, "#{val}")

formatForwardExpiry = (e) ->
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  target = e.target
  val     = QJ.val(target)

  if /^\d\d$/.test(val)
    QJ.val(target, "#{val} / ")

formatForwardSlash = (e) ->
  slash = String.fromCharCode(e.which)
  return unless slash is '/'

  target = e.target
  val     = QJ.val(target)

  if /^\d$/.test(val) and val isnt '0'
    QJ.val(target, "0#{val} / ")

formatBackExpiry = (e) ->
  # If shift+backspace is pressed
  return if e.metaKey

  target = e.target
  value   = QJ.val(target)

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if hasTextSelected(target)

  # Remove the trailing space
  if /\d(\s|\/)+$/.test(value)
    e.preventDefault()
    QJ.val(target, value.replace(/\d(\s|\/)*$/, ''))
  else if /\s\/\s?\d?$/.test(value)
    e.preventDefault()
    QJ.val(target, value.replace(/\s\/\s?\d?$/, ''))

# new events

inputExpire = (e) ->
  target = e.target
  value = QJ.val target
  # Chrome autocomplete fix
  if /^\d{2}\/\d{4}$/.test(value)
     matcher = /^(\d{2})\/(\d{4})$/.exec(value)
     value = matcher[1] + ' / ' + matcher[2].substring(2)
  if /^\d\d \/$/.test(value)
     setNewValue target, value.replace(/\D/g, '')
     return
  value = value.replace /\D/g, ''
  if value.length > 4
    setPreviewValue target
    month = value.substring(0,2)
    year = value.substring(2)
    if Payment.fns.validateCardExpiry(month, year)
      jumpToNext target
    else
      markAsInvalid target
    return
  if /^\d$/.test(value) and value != '0' and value != '1'
    setNewValue target, "0#{value} / "
    return
  if /^\d\d$/.test(value)
    if parseInt(value) > 12
      value = '12'
    setNewValue target, "#{value} / "
    return
  if /^\d\d\d*$/.test(value)
    month = value.substring(0,2)
    year = value.substring(2)
    setNewValue target, "#{month} / #{year}"
    if value.length == 4
      if Payment.fns.validateCardExpiry(month, year)
        jumpToNext target
      else
        markAsInvalid target
  return

inputExpireMonth = (e) ->
  target = e.target
  value = QJ.val target
  value = value.replace /\D/g, ''
  if value.length > 2
    setPreviewValue target
    jumpToNext target
    return
  if /^\d$/.test(value) and value != '0' and value != '1'
    value = "0#{value}"
    setNewValue target, value
  if /^\d\d$/.test(value)
    if parseInt(value) > 12
      value = '12'
    setNewValue target, value
  if value.length == 2
    jumpToNext target
  return

inputExpireYear = (e) ->
  target = e.target
  value = QJ.val target
  value = value.replace /\D/g, ''
  if value.length > 2
    setPreviewValue target
    jumpToNext target
    return
  if /^\d+$/.test(value)
    setNewValue target, "#{value}"
  if (value.length == 2)
    jumpToNext target
  return


inputCardNumber = (e) ->
  target = e.target
  value = QJ.val target
  value = Payment.fns.formatCardNumber(value)
  card = cardFromNumber(value)
  length = value.replace(/\D/g, '').length
  maxLength = 16
  if card
    for l in card.length
      maxLength = Math.max l, maxLength
  if length > maxLength
    setPreviewValue target
    if card and Payment.fns.validateCardNumber(value)
      jumpToNext target
    else
      markAsInvalid target
    return

  setNewValue target, value

  if length == maxLength
    if card and Payment.fns.validateCardNumber(value)
      jumpToNext target
    else
      markAsInvalid target
  return

pasteCVC = (e) ->
  setTimeout =>
    target = e.target
    value = QJ.val(target)
    value = value.replace /\D/g, ''
    if value.length > 3
      value = value.substring 0, 3
    QJ.val(target, value)

inputRestrictCVC = (e) ->
  target = e.target
  value = QJ.val target
  value = value.replace /\D/g, ''
  if not /^\d*/.test(value)
    setPreviewValue target
  if value.length > 3
    setNewValue target, value.substring(0,3)
  if value.length == 3
    jumpToNext target

prevInputHandler = (e) ->
  target = e.target
  which = e.which || e.keyCode
  if which == 8 && QJ.val(target).length == 0
    prev = QJ.data target, 'prev-input'
    if prev
      prev.focus()
      try
        prev.setSelectionRange && prev.setSelectionRange(QJ.val(prev).length, QJ.val(prev).length)


jumpToNext = (el) ->

  if el and QJ.data(el,'next-input')
    next = QJ.data el, 'next-input'
    next.focus()
    setTimeout ->
      try
        next.select && next.select()
        next.setSelectionRange && next.setSelectionRange(0, QJ.val(next).length)
  return

removeInvalidMarkHander = (e) ->
  el = e.target
  which = e.which || e.keyCode
  if which == 9
    return
  QJ.removeClass el, 'error'

markAsInvalid = (el) ->
  QJ.addClass el, 'error'

rememberPrevValue = (e) ->
  target = e.target
  QJ.data target, 'prev-value', target.value
  try
    QJ.data target, 'prev-start', target.selectionStart
  return

setNewValue = (el, newValue) ->
  prevValue = QJ.data el, 'prev-value'
  prevStart = QJ.data el, 'prev-start'
  if not prevValue then prevValue = ''
  if not prevStart
    prevStart = newValue.length + 1
  else
    prevStart += newValue.length - prevValue.length

  QJ.val el, newValue
  if el.setSelectionRange
    setTimeout ->
      try
        el.setSelectionRange prevStart, prevStart
  return

setPreviewValue = (el) ->
  prevValue = QJ.data el, 'prev-value'
  prevStart = QJ.data el, 'prev-start'
  if not prevValue then prevValue = ''
  if not prevStart then prevStart = prevValue.length

  QJ.val el, prevValue
  if el.setSelectionRange
    setTimeout ->
      try
        el.setSelectionRange prevStart, prevStart
  return

#  Restrictions

restrictNumeric = (e) ->
  # Key event is for a browser shortcut
  return true if e.metaKey or e.ctrlKey or e.originalEvent?.ctrlKey or e.originalEvent?.metaKey

  # If keycode is a space
  return e.preventDefault() if e.which is 32

  # If keycode is a special char (WebKit)
  return true if e.which is 0

  # If char is a special char (Firefox)
  return true if e.which < 33

  input = String.fromCharCode(e.which)

  # Char is a number or a space
  return e.preventDefault() if !/[\d\s]/.test(input)

restrictCardNumber = (e) ->
  target = e.target
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected(target)

  # Restrict number of digits
  value = (QJ.val(target) + digit).replace(/\D/g, '')
  card  = cardFromNumber(value)

  if card
    e.preventDefault() unless value.length <= card.length[card.length.length - 1]
  else
    # All other cards are 16 digits long
    e.preventDefault() unless value.length <= 16

restrictExpiry = (e, length) ->
  target = e.target
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected(target)

  value = QJ.val(target) + digit
  value = value.replace(/\D/g, '')

  return e.preventDefault() if value.length > length

restrictCombinedExpiry = (e) ->
  return restrictExpiry e, 4

restrictMonthExpiry = (e) ->
  return restrictExpiry e, 2

restrictYearExpiry = (e) ->
  return restrictExpiry e, 2

restrictCVC = (e) ->
  target = e.target
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected(target)

  val     = QJ.val(target) + digit
  return e.preventDefault() unless val.length <= 4

setCardType = (e) ->
  target  = e.target
  val      = QJ.val(target)
  cardType = Payment.fns.cardType(val) or 'unknown'

  unless QJ.hasClass(target, cardType)
    allTypes = (card.type for card in cards)

    QJ.removeClass target, 'unknown'
    QJ.removeClass target, allTypes.join(' ')

    QJ.addClass target, cardType
    QJ.toggleClass target.closest('.creditCard'), 'identified', cardType isnt 'unknown'
    QJ.toggleClass target, 'identified', cardType isnt 'unknown'
    QJ.trigger target, 'payment.cardType', cardType

# Public

class Payment
  @fns:
    cardExpiryVal: (value) ->
      value = value.replace(/\s/g, '')
      [month, year] = value.split('/', 2)

      # Allow for year shortcut
      if year?.length is 2 and /^\d+$/.test(year)
        prefix = (new Date).getFullYear()
        prefix = prefix.toString()[0..1]
        year   = prefix + year

      month = parseInt(month, 10)
      year  = parseInt(year, 10)

      month: month, year: year
    validateCardNumber: (num) ->
      num = (num + '').replace(/\s+|-/g, '')
      return false unless /^\d+$/.test(num)

      card = cardFromNumber(num)
      return false unless card

      num.length in card.length and
        (card.luhn is false or luhnCheck(num))
    validateCardExpiry: (month, year) ->
      # Allow passing an object
      if typeof month is 'object' and 'month' of month
        {month, year} = month
      else if typeof month is 'string' and '/' in month
        {month, year} = Payment.fns.cardExpiryVal(month)

      return false unless month and year

      month = QJ.trim(month)
      year  = QJ.trim(year)

      return false unless /^\d+$/.test(month)
      return false unless /^\d+$/.test(year)

      month = parseInt(month, 10)

      return false unless month and month <= 12

      if year.length is 2
        prefix = (new Date).getFullYear()
        prefix = prefix.toString()[0..1]
        year   = prefix + year

      expiry      = new Date(year, month)
      currentTime = new Date

      # Months start from 0 in JavaScript
      expiry.setMonth(expiry.getMonth() - 1)

      # The cc expires at the end of the month,
      # so we need to make the expiry the first day
      # of the month after
      expiry.setMonth(expiry.getMonth() + 1, 1)

      expiry > currentTime
    validateCardCVC: (cvc, type) ->
      cvc = QJ.trim(cvc)
      return false unless /^\d+$/.test(cvc)

      if type and cardFromType(type)
        # Check against a explicit card type
        cvc.length in cardFromType(type)?.cvcLength
      else
        # Check against all types
        cvc.length >= 3 and cvc.length <= 4
    cardType: (num) ->
      return null unless num
      cardFromNumber(num)?.type or null
    formatCardNumber: (num) ->
      card = cardFromNumber(num)
      return num unless card

      upperLength = card.length[card.length.length - 1]

      num = num.replace(/\D/g, '')
      num = num.slice(0, upperLength)

      if card.format.global
        num.match(card.format)?.join(' ')
      else
        groups = card.format.exec(num)
        groups?.shift()
        groups?.join(' ')
  @restrictNumeric: (el) ->
    QJ.on el, 'keypress', restrictNumeric
  @cardExpiryVal: (el) ->
    Payment.fns.cardExpiryVal(QJ.val(el))
  @formatCardCVC: (el) ->
    Payment.restrictNumeric el
#    QJ.on el, 'keypress', restrictCVC
    QJ.on el, 'keydown', rememberPrevValue
    QJ.on el, 'keydown', prevInputHandler
    QJ.on el, 'keydown', removeInvalidMarkHander
    QJ.on el, 'input', inputRestrictCVC
    QJ.on el, 'paste', pasteCVC
    el
  @formatCardExpiry: (el) ->
    Payment.restrictNumeric el
    if el.length && el.length == 2
      [month, year] = el
      @formatCardExpiryMultiple month, year
    else
      QJ.on el, 'keydown', rememberPrevValue
      QJ.on el, 'keydown', prevInputHandler
      QJ.on el, 'keydown', removeInvalidMarkHander
      QJ.on el, 'input', inputExpire
#      QJ.on el, 'keypress', restrictCombinedExpiry
#      QJ.on el, 'keypress', formatExpiry
#      QJ.on el, 'keypress', formatForwardSlash
#      QJ.on el, 'keypress', formatForwardExpiry
#      QJ.on el, 'keydown', formatBackExpiry
    el
  @formatCardExpiryMultiple: (month, year) ->
    QJ.on month, 'keydown', rememberPrevValue
    QJ.on year, 'keydown', rememberPrevValue
    QJ.on month, 'keydown', prevInputHandler
    QJ.on year, 'keydown', prevInputHandler
    QJ.on month, 'keydown', removeInvalidMarkHander
    QJ.on year, 'keydown', removeInvalidMarkHander

    QJ.on month, 'input', inputExpireMonth
    QJ.on year, 'input', inputExpireYear

#    QJ.on month, 'keypress', restrictMonthExpiry
#    QJ.on month, 'keypress', formatMonthExpiry
#    QJ.on year, 'keypress', restrictYearExpiry
  @formatCardNumber: (el) ->
    Payment.restrictNumeric el

#    QJ.on el, 'keypress', restrictCardNumber
    QJ.on el, 'keydown', rememberPrevValue
    QJ.on el, 'keydown', prevInputHandler
    QJ.on el, 'keydown', removeInvalidMarkHander
    QJ.on el, 'input', inputCardNumber
    QJ.on el, 'keypress', formatCardNumber

    QJ.on el, 'keydown', formatBackCardNumber
    QJ.on el, 'keyup', setCardType
    QJ.on el, 'paste', reFormatCardNumber
    el
  @getCardArray: -> return cards
  @setCardArray: (cardArray) ->
    cards = cardArray
    return true
  @addToCardArray: (cardObject) ->
    cards.push(cardObject)
  @removeFromCardArray: (type) ->
    for key, value of cards
      if(value.type == type)
        cards.splice(key, 1)
    return true

module.exports = Payment
global.Payment = Payment
