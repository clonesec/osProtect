class SensorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  before_action :set_sensor, only: [:edit, :update]

  def index
    # note: if current_user is an admin, groups/memberships don't matter since an admin can do anything:
    if current_user.role? :admin
      @sensors = Sensor.order(sid: :asc).page(params[:page]).per_page(APP_CONFIG[:per_page])
    else
      # get current_user's sensors based on group memberships:
      sensors_for_user = current_user.sensors
      if sensors_for_user.blank?
        sensors = []
        flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
        return
      else
        # limit Sensors based on this current_user's groups/memberships:
        @sensors = Sensor.where("sensor.sid IN (?)", sensors_for_user).order(sid: :asc).page(params[:page]).per_page(APP_CONFIG[:per_page])
      end
    end
  end

  def edit
  end

  def update
    # note: we are really creating/updating SensorName not Sensor, and it's ok
    #       for the name to be blank, so there are really no errors here
    sensor_name = @sensor.sensor_name
    if sensor_name
      sensor_name.update_attributes({name: params[:sensor][:name]})
    else
      SensorName.create(sensor_id: @sensor.id, name: params[:sensor][:name])
    end
    redirect_to sensors_url, notice: 'Sensor was successfully updated.'
  end

  private
    # use callbacks to share common setup or constraints between actions.
    def set_sensor
      @sensor = Sensor.find(params[:id])
    end

    # never trust parameters from the scary internet, only allow the white list through.
    def sensor_params
      params.require(:user).permit(:name)
    end
end
