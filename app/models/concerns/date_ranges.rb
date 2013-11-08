module DateRanges
  extend ActiveSupport::Concern

  def set_time_range(range)
    @start_time = nil
    @end_time = nil
    return if range.blank?
    range = range.to_sym
    case range
    when :last_24
      @start_time = Time.now.utc.yesterday
      @end_time = Time.now.utc
    when :yesterday
      @start_time = (Time.now.utc - 1.day).beginning_of_day
      @end_time = (Time.now.utc - 1.day).end_of_day
    when :week
      @start_time = Time.now.utc.beginning_of_week(start_day = :sunday)
      @end_time = Time.now.utc.end_of_week(start_day = :sunday)
    when :last_week
      @start_time = (Time.now.utc - 1.week).beginning_of_week(start_day = :sunday)
      @end_time = (Time.now.utc - 1.week).end_of_week(start_day = :sunday)
    when :month
      @start_time = Time.now.utc.beginning_of_month
      @end_time = Time.now.utc.end_of_month
    when :last_month
      @start_time = (Time.now.utc - 1.months).beginning_of_month
      @end_time = (Time.now.utc - 1.months).end_of_month
    when :quarter
      @start_time = Time.now.utc.beginning_of_quarter
      @end_time = Time.now.utc.end_of_quarter
    when :past_year
      @start_time = (Time.now.utc - 12.months)
      @end_time = Time.now.utc
    when :year
      @start_time = Time.now.utc.beginning_of_year
      @end_time = Time.now.utc.end_of_year
    when :today
      @start_time = Time.now.utc.beginning_of_day
      @end_time = Time.now.utc.end_of_day
    else
      @start_time = nil
      @end_time = nil
    end
  end
end
