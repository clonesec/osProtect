jQuery ->
	$(".report_date").datepicker({dateFormat: 'yy-mm-dd'})
	# $(document).on 'ready page:load', -> $('.report_date').datepicker({
	#     format: 'yy-mm-dd'
	#     autoclose: true
	#     todayHighlight: true
	# });

	$(".signatures").select2
	  placeholder: "click or type"
	  allowClear: true
	  # width: "resolve"

  $('#report form').nestedFields()
  # $('#report form').nestedFields
  #   beforeInsert: (item) ->
  #     console.log "nestedFields beforeInsert:"
  #     item.css
  #       "background-color": "manilla"
  #     # item.html
  #     #   "h1": 'mollyDog'
  #     console.log item
  #     # $this = $(item)
  #     # $this.select2
  #     # console.log $this
  #     item.select2
  #       placeholder: "big ole dog"
  #     console.log item
  #   afterInsert: (item) ->
  #     console.log "nestedFields afterInsert:"
  #     console.log item

  $('.events_listing #q_sig_priority').attr('disabled',true)
  $('.events_listing #q_sig_id').attr('disabled',true)
  $('.events_listing #q_source_address').attr('disabled',true)
  $('.events_listing #q_source_port').attr('disabled',true)
  $('.events_listing #q_destination_address').attr('disabled',true)
  $('.events_listing #q_destination_port').attr('disabled',true)
  $('.events_listing #q_sensor_id').attr('disabled',true)
  $('.events_listing #q_relative_date_range').attr('disabled',true)
  $('.events_listing #q_timestamp_gte').attr('disabled',true)
  $('.events_listing #q_timestamp_te').attr('disabled',true)

  # show/hide groups/sensor if 'Access Allowed' 'To' is 'for group(s) selected below'(g):
  # also hide sensor criteria when groups are shown:
  aat = $(".inputs .access_allowed #report_accessible_by option:selected").val()
  if aat == 'g'
    $('.groups').show()
    $('.sensor').hide()
  else
    $('.groups').hide()
    $('.sensor').show()

  $('.inputs .access_allowed #report_accessible_by').change ->
    att = $(".inputs .access_allowed #report_accessible_by option:selected").val()
    if att == 'g'
      $('.groups').show()
      $('.sensor').hide()
    else
      $('.groups').hide()
      $('.sensor').show()
    return true

  # if Run Automatically is Daily/Weekly/Monthly then don't show date ranges:
  rara = $(".inputs .auto_run #report_auto_run_at option:selected").text()
  if rara == ''
    $('.date_ranges').show()
    $('#set_access_allowed').show()
    $('#allow_all').hide()
  else
    $('.date_ranges').hide()
    $('#set_access_allowed').hide()
    $('#allow_all').show()

  # show/hide date ranges if Run Automatically is Daily/Weekly/Monthly or not selected(blank):
  $('.inputs .auto_run #report_auto_run_at').change ->
    s = $(".inputs .auto_run #report_auto_run_at option:selected").text()
    if s == ''
      $('.date_ranges').show()
      $('#set_access_allowed').show()
      $('#allow_all').hide()
    else
      $('.date_ranges').hide()
      $('#set_access_allowed').hide()
      $('#allow_all').show()
    return true

  $('#show_report_details').find('*').prop('disabled',true);