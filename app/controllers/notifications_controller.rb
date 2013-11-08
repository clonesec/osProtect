class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  before_filter :can_do_notifications
  before_action :set_notification, only: [:edit, :update, :destroy]

  # ActionController::Parameters.permit_all_parameters = true

  def index
    @notifications = current_user.notifications.order("updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to notifications_url
  end

  def new
    @notification = Notification.new
    @event_search = EventSearch.new(nil)
  end

  def create
    # adjust_params
    @notification = Notification.new(notification_params)
    @notification.events_in_email = true # always include matching events in report
    adjust_attributes
    if @notification.save
      redirect_to @notification, notice: 'Notification was successfully created, and you will receive an email when matches occur.'
    else
      @event_search = EventSearch.new(params[:q])
      render action: "new"
    end
  end

  def edit
    @event_search = EventSearch.new(@notification.notify_criteria)
  end

  def update
    # adjust_params
    @notification.events_in_email = true # always include matching events in report
    adjust_attributes
    if @notification.update_attributes(notification_params)
      redirect_to @notification, notice: 'Notification was successfully updated.'
    else
      @event_search = EventSearch.new(params[:q])
      render action: "edit"
    end
  end

  def destroy
    @notification.destroy
    redirect_to notifications_url
  end

  private

  def can_do_notifications
    return if APP_CONFIG[:can_do_notifications]
    flash[:error] = "Access denied: Notifications are not available."
    redirect_to root_url
  end

  def adjust_params
    # "select2" is sending a blank signature id, so let's remove it:
    unless params[:notification][:notification_signature_sections_attributes].blank?
      params[:notification][:notification_signature_sections_attributes].each do |k,v|
puts "k=#{k}\nv=#{v[:signature_ids].inspect}\nparams=#{params[:notification][:notification_signature_sections_attributes][k].class}\n"
puts "params=#{params[:notification][:notification_signature_sections_attributes][k][:signature_ids].length}\n"
        # params[:notification][:notification_signature_sections_attributes][k][:signature_ids].reject!{|si| si == ""}
        # params[:notification][:notification_signature_sections_attributes][k][:signature_ids].reject!{|si| si.blank? || (si.length <= 0)}
        puts params[:notification][:notification_signature_sections_attributes].inspect
        puts params[:notification][:notification_signature_sections_attributes].delete(k)
        puts params[:notification][:notification_signature_sections_attributes].inspect
      end
    end
  end

  def adjust_attributes
    # ignore date ranges by resetting them:
    params[:q][:relative_date_range] = ""
    params[:q][:timestamp_gte] = ""
    params[:q][:timestamp_lte] = ""
    @notification.user_id = current_user.id if @notification.user_id.blank? # preserve the original creator/owner id
    @notification.notify_criteria = params[:q]
  end

  # use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  # never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    # puts "params.permitted?=#{params.permitted?}"
    # params.require(:notification).permit!
    params.require(:notification).permit(
      :user_id, :email, :name, :description, :events_in_email, :run_status,
      :notify_criteria, :notify_criteria_as_string,
      notification_signature_sections_attributes: [:id, :_destroy, :title, :description, :signature_ids => []]
    )
  end
end
