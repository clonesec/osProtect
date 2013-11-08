$('#adding-events-spinner').hide()

$('#incident').empty()
$('#incident').show()

$('<%= escape_javascript(render(:partial => 'incident', locals: {incident: @incident}))%>')
  .appendTo('#incident')
  .hide()
  .fadeIn()

$(".select-events").attr('checked', false);

$('#add-selected-events').show()
$('#submit-selected-events').removeAttr('disabled')
