class CronTask

  # this class allows us to use one class with the method to perform passed in:
  class << self
    def perform(method)
      self.new.send(method)
      # with_logging method do
      #   self.new.send(method)
      # end
    end

    def with_logging(method, &block)
      log("starting...", method)
      time = Benchmark.ms do
        yield block
      end
      log("completed in (%.1fms)" % [time], method)
    end

    def log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      elapsed = "#{now} %s#%s - #{message}" % [self.name, method]
      puts elapsed
    end
  end

  def no_events_yesterday
    # logfile = File.open(File.join(Rails.root, 'log', 'resque.log'), 'a')
    # file = open('log/resque.log', 'a')
    # file.puts "CronTask::no_events_yesterday:"
    start_time = (Time.now.utc - 1.day).beginning_of_day
    end_time = (Time.now.utc - 1.day).end_of_day
    events = Event.where("timestamp >= ? AND timestamp <= ?", start_time, end_time)
    # file.puts "events.count=#{events.count.inspect}"
    # grab all admins and see if they want to be notified that yesterday has no events:
    Membership.where(role: 'admin').includes(:user).each do |member|
      admin = member.user
      next if admin.email.blank?
      next unless admin.no_events_yesterday_notification
      next unless events.count <= 0 # only email if no events for yesterday
      UserBackgroundMailer.no_events_yesterday(admin.id, start_time, end_time).deliver
    end
    # file.close
  end

  def batched_email_notifications
    return # deprecated Nov 2013 to enhance email notifications to send a pdf
  end

  def event_notifications
    return # deprecated Nov 2013 see: notifications_emailed_as_html
  end

  def notifications_emailed_as_html
    return unless APP_CONFIG[:can_do_notifications]
    start_time = Time.now.utc
    Notification.all.each do |notification|
      next if notification.disabled
      next if notification.user_id.blank? # no user to send an email
      UserBackgroundMailer.notification_report(notification.user_id, notification.id).deliver
    end
    puts "CronTask::notifications_emailed_as_html: elapsed: #{Time.now.utc - start_time}"
  end

  def daily_report_emailed_as_pdf
    return unless APP_CONFIG[:can_daily_report]
    Report.where(auto_run_at: 'd', run_status: true).each do |report|
      users = User.all
      # users = User.where(id: 1)
      users.each do |user|
        UserBackgroundMailer.events_cron_report(user.id, report.id).deliver if report.report_type == 1
        UserBackgroundMailer.incidents_cron_report(user.id, report.id).deliver if report.report_type == 2
      end
    end
  end

  def weekly_report_emailed_as_pdf
    return unless APP_CONFIG[:can_weekly_report]
    Report.where(auto_run_at: 'w', run_status: true).each do |report|
      users = User.all
      users.each do |user|
        UserBackgroundMailer.events_cron_report(user.id, report.id).deliver if report.report_type == 1
        UserBackgroundMailer.incidents_cron_report(user.id, report.id).deliver if report.report_type == 2
      end
    end
  end

  def monthly_report_emailed_as_pdf
    return unless APP_CONFIG[:can_monthly_report]
    Report.where(auto_run_at: 'm', run_status: true).each do |report|
      users = User.all
      users.each do |user|
        UserBackgroundMailer.events_cron_report(user.id, report.id).deliver if report.report_type == 1
        UserBackgroundMailer.incidents_cron_report(user.id, report.id).deliver if report.report_type == 2
      end
    end
  end

  private

  def log_it(msg)
    log = Log.new
    log.debug_msg = msg
    log.save(validate: false)
  end
end