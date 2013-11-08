class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup
  before_action :set_group, only: [:edit, :update, :destroy]

  # load_and_authorize_resource

  def index
    @groups = Group.order("updated_at desc").page(params[:page]).per_page(APP_CONFIG[:per_page])
  end

  def show
    redirect_to groups_url
  end

  def new
    @group = Group.new
  end

  def create
    # note: activerecord will ignore the empty values for user_ids/sensor_ids, so while 
    #       the following code isn't necessary it does make the situation clearer:
    params[:group][:user_ids].reject!(&:empty?) unless params[:group][:user_ids].blank?
    params[:group][:sensor_ids].reject!(&:empty?) unless params[:group][:sensor_ids].blank?
    @group = Group.new(group_params)
    if @group.save
      redirect_to groups_url, notice: 'Group was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    # note: activerecord will ignore the empty values for user_ids/sensor_ids, so while 
    #       the following code isn't necessary it does make the situation clearer:
    params[:group][:user_ids].reject!(&:empty?) unless params[:group][:user_ids].blank?
    params[:group][:sensor_ids].reject!(&:empty?) unless params[:group][:sensor_ids].blank?
    if @group.update_attributes(group_params)
      redirect_to groups_url, notice: 'Group was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    if @group.group_is_admins?
      flash[:error] = "Deleting the admins group is not allowed."
      redirect_to groups_url
      return 
    end
    @group.destroy
    redirect_to groups_url
  end

  private
    # use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, {:user_ids => []}, :user_tokens, {:sensor_ids => []})
    end
end
