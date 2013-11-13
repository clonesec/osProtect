jQuery ->
	checkAll = ->
	  $('input:checkbox').attr('checked','checked')
	  $(this).val('')

	uncheckAll = ->
	  $('input:checkbox').removeAttr('checked')
	  $(this).val('')

  $("#incidents-check").toggleClick checkAll, uncheckAll

	# Nov 2013: the deprecated ".toggle" was replaced 
	#           with ".toggleClick" see: app/assets/javascripts/toggleClick.js
	#           ... in time, we can remove jquery-migrate-1.1.1.js when all 
	#           ".toggle"s are replaced
	# Feb 2013: the toggle(fn,fn) function was deprecated in jQuery 1.7
	#           and was finally removed in 1.9, so until someone re-codes this
	#           properly we are forced to use jquery-migrate-1.1.1.js
	#           ... this solution is definitely not the way forward!
  # $('#incidents-check').toggle(
  #   ->
  #     $('input:checkbox').attr('checked','checked')
  #     $(this).val('')
  #   ,
  #   ->
  #     $('input:checkbox').removeAttr('checked')
  #     $(this).val('')
  # )

  $('form#delete_selected_incidents').on 'ajax:beforeSend', () ->
    $('#image_beside_button').hide()
    $('#deleting-incidents-spinner').show()
    $('#submit_selected_incidents_for_deletion').attr('disabled',true)
