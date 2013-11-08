class RulesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_user_is_setup

  # load_and_authorize_resource

  def index
    # list all rules in file
    @rules_location = RulesLocation.find(params[:id])
    @rules = results = []
    @count = 0
    @valid_response = false
    @borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
    if @borrowed
      @file_path = @borrowed.file_path
      @valid_response = true
      @rules = Rule.where(rules_location_id: @rules_location.id).order('linenum ASC').page(params[:page]).per_page(APP_CONFIG[:per_page])
      @count = @rules.count
    else
      # URL: <%= @response.request.url %><br />
      # cURL error: <%= @response.curl_error_message %><br />
      # cURL return code: <%= @response.curl_return_code.to_s %><br />
      # HTTP response code: <%= @response.code.to_s %><br />
      # HTTP status: <%= @response.status_message %><br />
      # Rules sentinel errors: <%= @errors %>
      @rules_service = RulesService.new(@rules_location)
      @rules_service.list_rules_in_file(params[:file])
      @file_path = @rules_service.file_path
      @uri = @rules_service.uri
      @errors = @rules_service.errors
      @count = @rules_service.count
      @results = @rules_service.results
      if @errors.blank?
        @borrowed = BorrowedRuleFile.new
        @borrowed.user_id = current_user.id
        @borrowed.rules_location_id = @rules_location.id
        @borrowed.file_name = params[:file]
        @borrowed.file_path = @rules_service.file_path
        @borrowed.save
        all_rules = Rule.new
        all_rules.mass_insert_initialize(@rules_location.id)
        # note: since .readlines is used to read the file each array element/line contains a linefeed ("\n")
        @results.each do |rule_line|
          all_rules.rawtext = rule_line
          all_rules.append_line_to_mass_insert_values
        end
        all_rules.mass_insert_into_rules_table
      end
      @rules = Rule.where(rules_location_id: @rules_location.id).order('linenum ASC').page(params[:page]).per_page(APP_CONFIG[:per_page])
      @count = @rules.count
    end
  end

  def show
    flash[:error] = "Access denied."
    redirect_to rules_locations_url
  end

  def new
    @rule = Rule.new
    @borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
  end

  def create
    remove_crlfs(params[:rule][:rawtext])
    params[:rule][:rawtext] = params[:rule][:rawtext] + "\n" # ensure linefeed at end of line
    @borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
    @rule = Rule.new(params[:rule])
    @rule.rules_location_id = @borrowed.rules_location_id
    @rule.linenum = Rule.next_linenum
    if @rule.save
      redirect_to rules_url(id: @rule.rules_location.id), notice: "The rule on line ##{@rule.linenum} was created, cached, and this rules file is waiting to be return."
    else
      render action: "new"
    end
  end

  def edit
    @rule = Rule.find(params[:id])
    @borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
  end

  def update
    @rule = Rule.find(params[:id])
    remove_crlfs(params[:rule][:rawtext])
    params[:rule][:rawtext] = params[:rule][:rawtext] + "\n" # ensure linefeed at end of line
    if @rule.update_attributes(params[:rule])
      redirect_to rules_url(id: @rule.rules_location.id), notice: "The rule on line ##{@rule.linenum} was updated, cached, and this rules file is waiting to be return."
    else
      render action: "edit"
    end
  end

  def return_rule_file
    borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
    rules_location = RulesLocation.find(borrowed.rules_location_id)
    @rules_service = RulesService.new(rules_location)
    @rules_service.write_rules_to_file(borrowed)
    @file_path = @rules_service.file_path
    @uri = @rules_service.uri
    @errors = @rules_service.errors
    @count = @rules_service.count
    @results = @rules_service.results
    if @errors.blank?
      Rule.where(rules_location_id: borrowed.rules_location_id).delete_all
      borrowed.delete
      redirect_to rules_locations_url(id: rules_location.id), notice: "Updated the rules file #{@results}"
    else
      flash[:error] = @errors
      redirect_to rules_locations_url
    end
  end

  def cancel_rule_file
    borrowed = BorrowedRuleFile.find_by_user_id(current_user.id)
    borrowed_file = borrowed.file_path
    rules_location = RulesLocation.find(borrowed.rules_location_id)
    Rule.where(rules_location_id: borrowed.rules_location_id).delete_all
    borrowed.delete
    redirect_to rules_locations_url(id: rules_location.id), notice: "Cancelled changes to the rules file #{borrowed_file}"
  end

  def destroy
    flash[:error] = "Access denied."
    redirect_to rules_locations_url
  end

  private

  def remove_crlfs(rule_text)
    # ensure a rule remains just one line:
    rule_text.gsub!(/\r\n/, "")  # remove CrLf's (Windows)
    rule_text.gsub!(/\r/, "")    # remove Cr's
  end
end
