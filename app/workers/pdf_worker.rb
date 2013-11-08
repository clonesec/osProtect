class PdfWorker
  @queue = :pdf_worker
  @queue_name = "PdfWorker"

  def self.perform(user_id, pdf_id)
    log("starting...", @queue_name)
    @user = User.find(user_id)
    @pdf = Pdf.find(pdf_id)
    time = Benchmark.ms do
      max_events_per_pdf = APP_CONFIG[:max_events_per_pdf]
      # types of pdf's:
      #   1 - EventsReport with optional summary(pulse) page
      #   2 - IncidentsReport with description+resolution and their events
      #   3 - EventsSearch, directly from the events page
      report_name = 'events_report'
      report_name = "events_report_#{@pdf.report_id}" unless @pdf.report_id.nil?
      report_name = "events_search_#{@pdf.id}" if @pdf.pdf_type == 3
      if @pdf.pdf_type == 1
        @report = @pdf.report
        @header = "Report Name: " + @report.name
        @report.name = "'" + @report.name + "' Report"
      elsif @pdf.pdf_type == 3
        # temporary Report for pdf's based on searches from the Events page:
        @report = Report.new
        @report.report_criteria = @pdf.creation_criteria
        @report.name = 'Events Page Search'
      else
        return
      end
      event = Event.new
      @events = event.get_events_based_on_groups_for_user(@user.id) # sets @events
      @event_search = EventSearch.new(@report.report_criteria)
      @events = @event_search.filter(@events) # sets: @start_time and @end_time
      report_title = set_report_title(@report.name, @event_search.start_time, @event_search.end_time)
      report_header = @header
      report_time = set_report_time(@event_search.start_time, @event_search.end_time)
      events_count = @events.count
      max_exceeded = (events_count > max_events_per_pdf) ? true : false
      @events = @events.limit(max_events_per_pdf)
      pdf_doc = EventsPdf.new(@user, @report, report_title, report_header, report_time, max_exceeded, max_events_per_pdf, events_count, @events)
      # now save pdf to file:
      path = "#{APP_CONFIG[:reports_path]}/#{user_id}"
      FileUtils.mkdir_p(path) # create path if it doesn't exist already
      filename = "#{Time.now.utc.strftime("%Y%m%d%H%M%S%N%Z")}_#{report_name}.pdf"
      pdf_file = pdf_doc.render_file("#{path}/#{filename}")
      if pdf_file.is_a? File
        @pdf.path_to_file = path
        @pdf.file_name = filename
        @pdf.save!
      end
    end
    log("completed in (%.1fms)" % [time], @queue_name)
  end

  def self.log(message, method = nil)
    now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    elapsed = "#{now} %s#%s - #{message}" % [self.name, method]
    puts elapsed
  end

  private

  def self.set_report_title(name, start_time, end_time)
    title = name
    if start_time.blank? && end_time.blank?
      title += 'For: any time period'
    elsif !start_time.blank? && end_time.blank?
      title += ' On or after: ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
    elsif start_time.blank? && !end_time.blank?
      title += ' On or before: ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
    else
      title += ' For: ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") + ' - ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
    end
    title
  end

  def self.set_report_time(start_time, end_time)
    report_time_window = ''
    if start_time.blank? && end_time.blank?
      report_time_window += 'For: any time period'
    elsif !start_time.blank? && end_time.blank?
      report_time_window += 'On or after: ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
    elsif start_time.blank? && !end_time.blank?
      report_time_window += 'On or before: ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
    else
      report_time_window += 'For: ' + start_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z") + ' - ' + end_time.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")
    end
    report_time_window
  end
end
