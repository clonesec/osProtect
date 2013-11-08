class IncidentEventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  def destroy
    incident_event = IncidentEvent.find(params[:id])
    incident = current_user.incidents.find(incident_event.incident)
    incident_event.destroy
    redirect_to edit_incident_url(id: incident.id)
  end
end
