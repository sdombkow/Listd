# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

updatePasses = ->
  pass_set_id = $("#passPoller").attr("data-id")
  after = $(".passPoller:last").attr("data-time")
  $.getScript "/bars/:bar_id/pass_sets.js?pass_set_id=" + pass_set_id + "&after=" + after
  setTimeout updatePasses, 20000
$ ->
  setTimeout updatePasses, 20000  if $("#passPoller").length > 0
