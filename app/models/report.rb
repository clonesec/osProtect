class Report < ActiveRecord::Base
  belongs_to :user
  has_many :report_groups, dependent: :destroy
  has_many :groups, through: :report_groups
  has_many :pdfs, dependent: :destroy
  has_many :report_signature_sections, inverse_of: :report, dependent: :destroy
  accepts_nested_attributes_for :report_signature_sections, allow_destroy: true

  attr_accessor :accessible_by, :signatures

  serialize :report_criteria, ActiveSupport::HashWithIndifferentAccess

  # Nov 2013: doesn't work in Rails 4, but it's unused anyways:
  # before_validation :set_report_criteria_as_string

  # Feb 2013: allow duplicate Reports with similar match criteria as it's
  #           too difficult to check accurately, so let the users handle this:
  # validates :report_criteria_as_string, uniqueness: {scope: :user_id, message: "a similar Report already exists"}
  validates :name, presence: true

  # validate :include_summary_or_events_selected_as_yes
  validate :group_ids_ok
  validate :source_address_ok
  validate :source_port_ok
  validate :destination_address_ok
  validate :destination_port_ok
  validate :timestamp_gte_ok
  validate :timestamp_lte_ok
  validate :date_range_presence
  validate :date_range_is_relative_or_fixed_but_not_both
  validate :date_range_is_fixed_so_both_dates_required
  validate :date_range_is_fixed_so_range_must_be_proper

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def self.relative_date_ranges
    rdr = []
    rdr << Selection.new({id: 'today',      name: 'Today'})
    rdr << Selection.new({id: 'last_24',    name: 'Last 24 Hours'})
    rdr << Selection.new({id: 'week',       name: 'This Week'})
    rdr << Selection.new({id: 'last_week',  name: 'Last Week'})
    rdr << Selection.new({id: 'month',      name: 'This Month'})
    rdr << Selection.new({id: 'last_month', name: 'Last Month'})
    rdr << Selection.new({id: 'past_year',  name: 'Past Year'})
    rdr << Selection.new({id: 'year',       name: 'Year'})
    rdr
  end

  def self.auto_run_selections
    ar = []
    ar << Selection.new({id: 'd', name: 'Daily'})   if APP_CONFIG[:can_daily_report]
    ar << Selection.new({id: 'w', name: 'Weekly'})  if APP_CONFIG[:can_weekly_report]
    ar << Selection.new({id: 'm', name: 'Monthly'}) if APP_CONFIG[:can_monthly_report]
    ar
  end

  def self.access_allowed_selections(user)
    ar = []
    ar << Selection.new({id: 'm', name: 'only me'})
    ar << Selection.new({id: 'a', name: 'any group or user'}) if user && user.role?(:admin)
    ar << Selection.new({id: 'g', name: 'for group(s) selected below'})
    ar
  end

  def enabled
    self.run_status == true
  end

  def disabled
    self.run_status == false
  end

  def auto_run_at_to_s
    return "" if self.auto_run_at.blank?
    return Report.auto_run_selections.select {|p| p.id == self.auto_run_at}.first.name
  end

  def is_auto_run?
    return false if self.auto_run_at.blank?
    return Report.auto_run_selections.select {|p| p.id == self.auto_run_at}.first.id == self.auto_run_at
  end

  def status
    self.run_status ? 'enabled' : 'disabled'
  end

  def group_ids_as_array
    gids = []
    self.groups.map {|g| gids << g.id}
    gids
  end

  def users_pdf_count_for_this_report(user_id, user_is_admin=false)
    if user_is_admin
      Pdf.includes(:report).where(report_id: self.id).count
    else
      Pdf.includes(:report, :user).where(user_id: user_id, report_id: self.id).count
    end
  end

  private

  def set_report_criteria_as_string
    self.report_criteria_as_string =  "report=#{self.report_type}," +
                                      "include_summary=#{self.include_summary}," +
                                      "auto_run_at=#{self.auto_run_at}," +
                                      self.report_criteria.to_s
  end

  def include_summary_or_events_selected_as_yes
    return if self.report_type == 2
    return if self.include_summary || self.include_events
    self.errors[:include_summary] << "or Include Events or both must be selected as yes"
  end

  def group_ids_ok
    self.errors[:group_ids] << "missing Group selection(s)" if self.accessible_by == 'g' && self.groups.blank?
    self.errors[:group_ids] << "Group(s) selected but 'To' is 'only me'" if self.accessible_by == 'm' && self.groups.any?
    self.errors[:group_ids] << "Group(s) selected but 'To' is 'any group or user'" if self.accessible_by == 'a' && self.groups.any?
  end

  def source_address_ok
    self.errors[:source_address] << "is invalid" unless Iphdr.is_valid?(self.report_criteria[:source_address])
  end

  def source_port_ok
    self.errors[:source_port] << "must be a number" unless Iphdr.numeric?(self.report_criteria[:source_port])
  end

  def destination_address_ok
    self.errors[:destination_address] << "is invalid" unless Iphdr.is_valid?(self.report_criteria[:destination_address])
  end

  def destination_port_ok
    self.errors[:destination_port] << "must be a number" unless Iphdr.numeric?(self.report_criteria[:destination_port])
  end

  def timestamp_gte_ok
    return unless self.auto_run_at.blank?
    self.errors[:timestamp_gte] << "is invalid" unless valid_date? self.report_criteria[:timestamp_gte]
  end

  def timestamp_lte_ok
    return unless self.auto_run_at.blank?
    self.errors[:timestamp_lte] << "is invalid" unless valid_date? self.report_criteria[:timestamp_lte]
  end

  def date_range_presence
    return unless self.auto_run_at.blank?
    self.errors[:date_range] << "a relative or fixed date range is required" if self.report_criteria[:relative_date_range].blank? && self.report_criteria[:timestamp_gte].blank? && self.report_criteria[:timestamp_lte].blank?
  end

  def date_range_is_relative_or_fixed_but_not_both
    return unless self.auto_run_at.blank?
    self.errors[:date_range] << "can not be both relative and fixed, please enter only a relative or fixed date range" if self.report_criteria[:relative_date_range].present? && (self.report_criteria[:timestamp_gte].present? || self.report_criteria[:timestamp_lte].present?)
  end

  def date_range_is_fixed_so_both_dates_required
    return unless self.auto_run_at.blank?
    if (self.report_criteria[:timestamp_lte].present? && self.report_criteria[:timestamp_gte].blank?) ||
       (self.report_criteria[:timestamp_gte].present? && self.report_criteria[:timestamp_lte].blank?)
      self.errors[:fixed_date_range] << "both dates are required when either is entered"
    end
  end

  def date_range_is_fixed_so_range_must_be_proper
    return unless self.auto_run_at.blank?
    return if self.report_criteria[:timestamp_lte].blank? && self.report_criteria[:timestamp_gte].blank?
    begin
      self.errors[:fixed_date_range] << "begin and end dates must specify a proper range" if self.report_criteria[:timestamp_lte].to_date < self.report_criteria[:timestamp_gte].to_date
    rescue Exception => e
      return # invalid dates already handled by another validation
    end
  end

  def valid_date?(adate)
    adate.to_date
    true
  rescue Exception => e
    false
  end
end
