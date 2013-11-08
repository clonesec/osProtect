module PulseTopTens
  extend ActiveSupport::Concern

  def take_pulse(user, date_range)
    set_time_range(date_range)
    if @start_time.nil? || @end_time.nil?
      # relative didn't work, so try fixed date range:
      @start_time = Time.parse("#{@report.report_criteria[:timestamp_gte]} 00:00:00 +0000")
      @end_time = Time.parse("#{@report.report_criteria[:timestamp_lte]} 23:59:59 +0000")
    end
    # note: if user is an admin, groups/memberships don't matter since an admin can do anything:
    if user.role? :admin
      # note: the sql used to find the most active times is too slow, so this is disabled:
      # every 15 minutes (900 seconds = 15  * 60):
      # @hot_times = Event.find_by_sql ["SELECT SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) AS `minute`, count(*) as `cnt` from event where timestamp BETWEEN ? AND ? GROUP BY SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) HAVING `cnt` > 10", @start_time, @end_time]
      @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).order('sig_priority asc')
      @priorities = @priorities.where('timestamp between ? and ?', @start_time, @end_time)
      @attackers = Iphdr.select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) AS ipcnt").group('iphdr.sid', 'iphdr.ip_src')
      @attackers = @attackers.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @targets = Iphdr.select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group('iphdr.sid', 'iphdr.ip_dst')
      @targets = @targets.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @events_by_signature = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events)
      @events_by_signature = @events_by_signature.where('timestamp between ? and ?', @start_time, @end_time).limit(10)
      @events_count = @events_by_signature.length
    else
      # get user's Sensors based on group memberships:
      sensors_for_user = user.sensors
      if sensors_for_user.blank?
        @events_by_signature = []
        @incidents = []
        flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
        @events_count = 0
        return
      else
        # note: the sql used to find the most active times is too slow, so this is disabled:
        # every 15 minutes (900 seconds = 15  * 60):
        # @hot_times = Event.find_by_sql ["SELECT SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) AS `minute`, count(*) as `cnt` from event where event.sid IN (?) AND timestamp BETWEEN ? AND ? GROUP BY SEC_TO_TIME(FLOOR(TIME_TO_SEC(timestamp)/900)*900) HAVING `cnt` > 10", sensors_for_user, @start_time, @end_time]
        @priorities = SignatureDetail.select("#{SignatureDetail.table_name}.sig_priority, COUNT(#{SignatureDetail.table_name}.sig_priority) as priority_cnt").where("sig_priority IS NOT NULL").group(:sig_priority).joins(:events).where("event.sid IN (?)", sensors_for_user).order('sig_priority asc')
        @priorities = @priorities.where('timestamp between ? and ?', @start_time, @end_time)
        @attackers = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_src, COUNT(#{Iphdr.table_name}.ip_src) as ipcnt").group('iphdr.sid', 'iphdr.ip_src')
        @attackers = @attackers.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @targets = Iphdr.where("iphdr.sid IN (?)", sensors_for_user).select("#{Iphdr.table_name}.ip_dst, COUNT(#{Iphdr.table_name}.ip_dst) as ipcnt").group('iphdr.sid', 'iphdr.ip_dst')
        @targets = @targets.joins(:events).where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @events_by_signature = SignatureDetail.select("#{SignatureDetail.table_name}.sig_id, #{SignatureDetail.table_name}.sig_name, COUNT(#{SignatureDetail.table_name}.sig_name) as event_cnt").group(:sig_id, :sig_name).joins(:events).where("event.sid IN (?)", sensors_for_user)
        @events_by_signature = @events_by_signature.where('timestamp between ? and ?', @start_time, @end_time).limit(10)
        @events_count = @events_by_signature.length
      end
    end
  end
end
