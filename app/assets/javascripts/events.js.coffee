jQuery ->
  $(".datepicker").datepicker({dateFormat: 'yy-mm-dd'})
  # $(".datepicker").datepicker()

	# Feb 2013: the toggle(fn,fn) function signature was deprecated in jQuery 1.7
	#           and was finally removed in 1.9, so until someone re-codes this
	#           properly we are forced to use jquery-migrate-1.1.1.js
	#           ... this solution is definitely not the way forward!

  $('#events-check').toggle(
    ->
      $('input:checkbox').attr('checked','checked')
      $(this).val('')
    ,
    ->
      $('input:checkbox').removeAttr('checked')
      $(this).val('')
  )

  $('#search-sidebar').toggle(
    ->
      $('div#osprotect_content').attr('class','with_sidebar')
      $('#sidebar').show()
    ->
      $('div#osprotect_content').attr('class','without_sidebar')
      $('#sidebar').hide()
  )

  $('#search-sidebar-no-events').toggle(
    ->
      $('div#osprotect_content').attr('class','without_sidebar')
      $('#sidebar').hide()
    ->
      $('div#osprotect_content').attr('class','with_sidebar')
      $('#sidebar').show()
  )

  $('form.event_select_form').on 'ajax:beforeSend', () ->
    $('#add-selected-events').hide()
    $('#adding-events-spinner').show()
    $('#submit-selected-events').attr('disabled',true)
