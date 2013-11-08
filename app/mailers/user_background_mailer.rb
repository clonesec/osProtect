class UserBackgroundMailer < ActionMailer::Base
  include Resque::Mailer
  include DateRanges
  include RestrictEventsBasedOnUsersAccess

  default from: APP_CONFIG[:emails_from]

  def password_reset(user_id)
    @user = User.find(user_id)
    mail :to => @user.email, :subject => "Password Reset"
  end

  def no_events_yesterday(user_id, start_time, end_time)
    @user = User.find(user_id)
    @start_time = start_time # passed in as a String
    @end_time = end_time # passed in as a String
    mail :to => @user.email, :subject => "No Events Received Yesterday #{Time.now.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")}"
  end

  def batched_email_notifications(notification_id)
    return # deprecated Nov 2013 to enhance email notifications to send a pdf
  end

  def notification_report(user_id, notification_id)
    now_time = Time.now.utc
    one_minute_ago_time = 1.minute.ago
    start_time = Time.now.utc
    @user = User.find(user_id)
    @notification = Notification.find(notification_id)
    sensors = nil # admin's can see all sensors
    sensors = @notification.user.sensors unless @notification.user.role? :admin
    # "get_events_based_on_groups_for_user" gets all events for an admin user,
    # and gets events based on the sensors, per user's group, for this user:
    get_events_based_on_groups_for_user(@notification.user.id) # sets @events
    @notification.notify_criteria[:timestamp_gte] = one_minute_ago_time.to_s
    @notification.notify_criteria[:timestamp_lte] = now_time.to_s
    @event_search = EventSearch.new(@notification.notify_criteria)
    @event_search.signature_ids = @notification.notification_signature_sections.collect(&:signature_ids).flatten
    @events = @event_search.notification_filter(@events) # sets: @start_time and @end_time
    @events_count = @events.references(:signature).count
    return if @events_count < 1 # no events matched this notification
    if @events_count > APP_CONFIG[:max_events_that_can_be_copied_to_incidents_for_each_notification]
      @events = @events.limit(APP_CONFIG[:max_events_that_can_be_copied_to_incidents_for_each_notification])
    end
    ActiveRecord::Base.transaction do
      add_events_to_incident(@notification.id, @notification.name, @notification.description, @notification.user, @events)
    end
    # @report_header = 'Notification: ' + @notification.name
    # @report_title = set_report_title('', 'report for', @event_search.start_time, @event_search.end_time)
    @report_time = set_report_time(@event_search.start_time, @event_search.end_time)
    # set up PDF report:
    # report_header = 'Notification: ' + @notification.name
    # @report_title = set_report_title('', 'report for', @event_search.start_time, @event_search.end_time)
    # report_time = set_report_time(@event_search.start_time, @event_search.end_time)
    # max_exceeded = (@events_count > APP_CONFIG[:max_events_per_pdf]) ? true : false
    # @events = @events.limit(APP_CONFIG[:max_events_per_pdf])
    # if @events_count > 0
    #   pdf_doc = NotificationsPdf.new(@user, @notification, @report_title, report_header, report_time, max_exceeded, APP_CONFIG[:max_events_per_pdf], @events_count, @events)
    #   # now save pdf to a file and create a Pdf table entry:
    #   path = "#{APP_CONFIG[:reports_path]}/#{@user.id}/notifications"
    #   FileUtils.mkdir_p(path) # create path if it doesn't exist
    #   filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_notification_#{@notification.id}.pdf"
    #   path_and_filename = "#{path}/#{filename}"
    #   pdf_file = pdf_doc.render_file(path_and_filename)
    #   if pdf_file.is_a? File
    #     pdf = Pdf.new
    #     pdf.user_id = @user.id
    #     pdf.report_id = @notification.id
    #     pdf.pdf_type = 4 # notifications
    #     pdf.creation_criteria = @notification.notify_criteria
    #     pdf.path_to_file = path
    #     pdf.file_name = filename
    #     pdf.save!
    #   end
    #   # note: having Prawn render again is slower than just reading the file from disk:
    #   # attachments[filename] = pdf_doc.render
    #   attachments[filename] = File.read(path_and_filename)
    # end
    puts "UserBackgroundMailer::notification_report: elapsed: #{Time.now.utc - start_time}"
    # note: "mail :to..." must be the last line or no mail is sent!!!
    mail :to => @user.email, :subject => "#{@notification.name} #{Time.now.utc.strftime("%a %b %d, %Y")}"
  end

  def events_cron_report(user_id, report_id)
    start_time = Time.now.utc
    @user = User.find(user_id)
    @report = Report.find(report_id)
    @header = 'Report Name: ' + @report.name
    time_range = 'yesterday'  if @report.auto_run_at == 'd'
    time_range = 'last_week'  if @report.auto_run_at == 'w'
    time_range = 'last_month' if @report.auto_run_at == 'm'
    # time_range = 'today' if Rails.env.development?
    @report.report_criteria[:relative_date_range] = time_range
    get_events_based_on_groups_for_user(@user.id) # sets @events
    @event_search = EventSearch.new(@report.report_criteria)
    @event_search.signature_ids = @report.report_signature_sections.collect(&:signature_ids).flatten
    @events = @event_search.filter(@events) # sets: @start_time and @end_time
    # set up for PDF report
    @report_title = set_report_title(@report.auto_run_at, 'Events Report for', @event_search.start_time, @event_search.end_time)
    report_header = @header
    report_time = set_report_time(@event_search.start_time, @event_search.end_time)
    events_count = @events.references(:signature).count
    max_exceeded = (events_count > APP_CONFIG[:max_events_per_pdf]) ? true : false
    @events = @events.limit(APP_CONFIG[:max_events_per_pdf])
    # log_it("@events=#{@events.inspect}\nevents_count=#{events_count.inspect}")
    if events_count > 0
      pdf_doc = EventsPdf.new(@user, @report, @report_title, report_header, report_time, max_exceeded, APP_CONFIG[:max_events_per_pdf], events_count, @events)
      # now save pdf to a file and create a Pdf table entry:
      path = "#{APP_CONFIG[:reports_path]}/#{@user.id}/#{@report.auto_run_at}"
      FileUtils.mkdir_p(path) # create path if it doesn't exist
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_#{set_name(@report.auto_run_at)}_Events_report.pdf"
      path_and_filename = "#{path}/#{filename}"
      pdf_file = pdf_doc.render_file(path_and_filename)
      if pdf_file.is_a? File
        pdf = Pdf.new
        pdf.user_id = @user.id
        pdf.report_id = @report.id
        pdf.pdf_type = 1 # events
        pdf.creation_criteria = @report.report_criteria
        pdf.path_to_file = path
        pdf.file_name = filename
        pdf.save!
      end
      # note: having Prawn render again is slower than just reading the file from disk:
      # attachments[filename] = pdf_doc.render
      attachments[filename] = File.read(path_and_filename)
    end
    puts "UserBackgroundMailer::events_cron_report: elapsed: #{Time.now.utc - start_time}"
    # note: "mail :to..." must be the last line or no mail is sent!!!
    mail :to => @user.email, :subject => "#{@report.name} #{Time.now.utc.strftime("%a %b %d, %Y")}"
  end

  def incidents_cron_report(user_id, report_id)
    @user = User.find(user_id)
    @report = Report.find(report_id)
    @header = 'Report Name: ' + @report.name
    time_range = 'yesterday'  if @report.auto_run_at == 'd'
    time_range = 'last_week'  if @report.auto_run_at == 'w'
    time_range = 'last_month' if @report.auto_run_at == 'm'
    @report.report_criteria[:relative_date_range] = time_range
    if @user.role? :admin
      @incidents = Incident.includes(:incident_events).order("incidents.created_at DESC")
    else
      @incidents = Incident.where("sid IN (?)", @user.sensors).includes(:incident_events).order("incidents.created_at DESC")
    end
    @incident_event_search = IncidentEventSearch.new(@report.report_criteria)
    @incidents = @incident_event_search.filter(@incidents) # sets: @start_time and @end_time
    @report_title = set_report_title(@report.auto_run_at, 'Incidents Report for', @incident_event_search.start_time, @incident_event_search.end_time)
    report_header = @header
    report_time = set_report_time(@incident_event_search.start_time, @incident_event_search.end_time)
    @incidents_count = @incidents.count
    max_exceeded = (@incidents_count > APP_CONFIG[:max_incidents_per_pdf]) ? true : false
    @incidents = @incidents.limit(APP_CONFIG[:max_incidents_per_pdf])
    if @incidents_count > 0
      pdf_doc = IncidentsPdf.new(@user, @report, @report_title, report_header, report_time, max_exceeded, APP_CONFIG[:max_incidents_per_pdf], @incidents_count, @incidents)
      # now save pdf to a file and create a Pdf table entry:
      path = "#{APP_CONFIG[:reports_path]}/#{@user.id}/#{@report.auto_run_at}"
      FileUtils.mkdir_p(path) # create path if it doesn't exist
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_#{set_name(@report.auto_run_at)}_Incidents_report.pdf"
      path_and_filename = "#{path}/#{filename}"
      pdf_file = pdf_doc.render_file(path_and_filename)
      if pdf_file.is_a? File
        pdf = Pdf.new
        pdf.user_id = @user.id
        pdf.report_id = @report.id
        pdf.pdf_type = 2 # incidents
        pdf.creation_criteria = @report.report_criteria
        pdf.path_to_file = path
        pdf.file_name = filename
        pdf.save!
      end
      # note: having Prawn render again is slower than just reading the file from disk:
      # attachments[filename] = pdf_doc.render
      attachments[filename] = File.read(path_and_filename)
    end
    # mail :to => @user.email, :subject => "osProtect: #{@report_title}"
    # Feb 2013: change subject to:
    mail :to => @user.email, :subject => "#{@report.name} #{Time.now.utc.strftime("%a %b %d, %Y")}"
  end

  private

  def add_events_to_incident(notification_id, name, description, user, events)
    return nil if events.blank? || user.blank?
    incident = Incident.create(
      user_id: user.id,
      group_id: user.groups.first.id,
      incident_name: name,
      incident_description: description,
      notification_id: notification_id
    )
    events.each do |event|
      incident_events_attributes = IncidentEvent.set_attributes(event)
      incident.incident_events.build(incident_events_attributes)
    end
    incident.save(validate: false)
    incident || nil
  end

  def set_name(auto_run_at)
    case auto_run_at
    when 'd'
      name = 'Daily'
    when 'w'
      name = 'Weekly'
    when 'm'
      name = 'Monthly'
    else
      name = 'Notification'
    end
    name
  end

  def set_report_title(auto_run_at, type, start_time, end_time)
    name = set_name(auto_run_at)
    name + ' ' + type + ' ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") + ' - ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
  end

  def set_report_time(start_time, end_time)
    name = start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") + ' - ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
  end

  def log_it(msg)
    log = Log.new
    log.debug_msg = msg
    log.save
  end
end
