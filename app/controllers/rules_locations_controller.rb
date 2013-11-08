class RulesLocationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  # load_and_authorize_resource

  def index
    @rules_locations = RulesLocation.order("updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    # list all ".rules" files in a folder
    @borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
    @user_has_borrowed_file = @borrowed.blank? ? false : true
    @rules_location = RulesLocation.find(params[:id])
    @rules_service = RulesService.new(@rules_location)
    @rules_service.list_folder
    @uri = @rules_service.uri
    @errors = @rules_service.errors
    @count = @rules_service.count
    @files = @rules_service.results
  end

  def new
    @rules_location = RulesLocation.new
    @rules_location.rules_files_location = 'local'
  end

  def create
    @rules_location = RulesLocation.new(params[:rules_location])
    if @rules_location.save
      redirect_to rules_locations_url, notice: 'Rules location was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
    @rules_location = RulesLocation.find(params[:id])
    @rules_location.rules_files_location = @rules_location.url_domain_ip.blank? ? 'local' : 'remote'
  end

  def update
    @rules_location = RulesLocation.find(params[:id])
    if @rules_location.update_attributes(params[:rules_location])
      redirect_to rules_locations_url, notice: 'Rules location was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @rules_location = RulesLocation.find(params[:id])
    @rules_location.destroy
    redirect_to rules_locations_url
  end
end
