jQuery ->
  $("#topAttackers").click ->
    $('li#topAttackers').attr('class','current')
    $('li#topTargets').removeAttr('class')
    $('li#topEvents').removeAttr('class')
    $('#top_attackers').show()
    $('#top_targets').hide()
    $('#top_events').hide()

  $("#topTargets").click ->
    $('li#topAttackers').removeAttr('class')
    $('li#topTargets').attr('class','current')
    $('li#topEvents').removeAttr('class')
    $('#top_attackers').hide()
    $('#top_targets').show()
    $('#top_events').hide()

  $("#topEvents").click ->
    $('li#topAttackers').removeAttr('class')
    $('li#topTargets').removeAttr('class')
    $('li#topEvents').attr('class','current')
    $('#top_attackers').hide()
    $('#top_targets').hide()
    $('#top_events').show()

  # Feb 2013: this no longer works in jQuery 1.9+
  # $('.no_menu_link').toggle(
  #   ->
  #     $('#frequencybox').show()
  #   ->
  #     $('#frequencybox').hide()
  # )

  $(".no_menu_link").on "click", ->
    $("#frequencybox").toggle()

#  $('#pulseTimePeriod').change ->
#    optionSelectedValue = $('#pulseTimePeriod option:selected').val()
#    top.location.href = optionSelectedValue;
