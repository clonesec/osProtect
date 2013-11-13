url = window.location.href
if url.indexOf("?") > -1
  url += "&destroy_multiple_incidents_results_message=<%=@response%>"
else
  url += "?destroy_multiple_incidents_results_message=<%=@response%>"
window.location.href = url
# cls: the following isn't needed,
#      as the page has to be reloaded to show current incidents after deletions:
# $('#deleting-incidents-spinner').hide()
# $(".selected-incidents").attr('checked', false);
# $('#image_beside_button').show()
# $('#delete_selected_incidents').removeAttr('disabled')
