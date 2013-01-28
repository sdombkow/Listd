# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  purchase.setupForm()

purchase =
  setupForm: ->
    $('#new_purchase').submit ->
        $('input[type=button]').attr('disabled','disabled')
        $('a').addClass('inactiveLink')
        $('input[type=submit]').hide()
        $('#purchaseLoading').show()
        if $('#card_number').length
            purchase.processCard()
            false
        else
            true

  processCard: ->
    card =
      number: $('#card_number').val()
      cvc: $('#card_code').val()
      expMonth: $('#card_month').val()
      expYear: $('#card_year').val()
    Stripe.createToken(card, purchase.handleStripeResponse)
    false

  handleStripeResponse: (status, response) ->
    if status == 200
      $('#purchase_stripe_card_token').val(response.id)
      $('#new_purchase')[0].submit()
    else
      $('#stripe_error').text(response.error.message)
      $('#purchaseLoading').hide()
      $('input[type=submit]').show()
    $('input[type=button]').attr('disabled',false)
    $('a').removeClass('inactiveLink')

