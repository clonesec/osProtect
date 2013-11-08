class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_user_is_setup, only: [:index]
  # before_action :set_dashboard, only: [:show, :edit, :update, :destroy]

  include DateRanges
  include PulseTopTens

  def index
    params[:range] = 'today' if params[:range].blank?
    take_pulse(current_user, params[:range])
  end

  def user_setup_required
    # this allows to show a page telling user to have an admin set up their account
  end

  private
    # use callbacks to share common setup or constraints between actions.
    # def set_dashboard
    #   # @dashboard = Dashboard.find(params[:id])
    # end

    # never trust parameters from the scary internet, only allow the white list through.
    # def dashboard_params
    #   params.require(:dashboard).permit(:name)
    # end
end
