class IncidentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  before_action :set_incident, only: [:edit, :update, :destroy]

  respond_to :js, only: :destroy_multiple

  def index
    flash[:notice] = params[:destroy_multiple_incidents_results_message] unless params[:destroy_multiple_incidents_results_message].blank?
    @incidents = current_user.incidents.order(updated_at: :desc).page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to incidents_url
  end

  def new
    @incident = Incident.new
  end

  def create
    @incident = Incident.new(incident_params)
    @incident.user_id = current_user.id
    # FIXME any group that current_user is a member of will do, but if current_user's
    #       groups/members are changed this could lead to zombie incidents:
    @incident.group_id = current_user.groups.first.id
    if @incident.save
      redirect_to incidents_url, notice: 'Incident was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @incident_events = @incident.incident_events.page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def update
    # FIXME any group that current_user is a member of will do, but if current_user's
    #       groups/members are changed this could lead to zombie incidents:
    @incident.group_id = current_user.groups.first.id unless current_user.role? :admin # don't change owner
    if @incident.update_attributes(incident_params)
      redirect_to incidents_url, notice: 'Incident was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @incident.destroy
    redirect_to incidents_url
  end

  def destroy_multiple
    if params[:incident_ids].blank?
      # redirect_to incidents_url, notice: "No Incidents were selected for deletion!"
      @response = "No incidents were selected for deletion!"
    else
      Incident.destroy(params[:incident_ids])
      # redirect_to incidents_url, notice: "#{params[:incident_ids].length} Incidents were deleted."
      if params[:incident_ids].length > 1
        @response = "#{params[:incident_ids].length} incidents were deleted."
      else
        @response = "#{params[:incident_ids].length} incident was deleted."
      end
    end
  end

  private

  # use callbacks to share common setup or constraints between actions.
  def set_incident
    @incident = current_user.incidents.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def incident_params
    # puts "params.permitted?=#{params.permitted?}"
    params.require(:incident).permit!
    # params.require(:incident).permit(
    #   :user_id, :email, :name, :description, :events_in_email, :run_status,
    #   :notify_criteria, :notify_criteria_as_string,
    #   notification_signature_sections_attributes: [:id, :_destroy, :title, :description, :signature_ids => []]
    # )
  end

end
