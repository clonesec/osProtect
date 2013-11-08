require "open-uri"
class IncidentsPdf < Prawn::Document
  include DateRanges
  include PulseTopTens

  def initialize(user, report, report_title, report_header, report_time, max_exceeded, max_incidents_per_pdf, incidents_count, incidents)
    super(top_margin: 30, left_margin: 5, right_margin: 5, font: "Helvetica", page_size: "A4", page_layout: :portrait)
    self.font_size = 8
    @gchart_size = '900x300'
    @user = user
    @report = report
    @report_title = report_title
    @report_header = report_header
    @report_time = report_time
    @max_exceeded = max_exceeded
    @max_incidents_per_pdf = max_incidents_per_pdf
    @incidents_count = incidents_count
    @incidents = incidents
    @coverbg = "app/assets/images/osProtect-background.jpg"
    # set_title_for_every_page
    image @coverbg, :at => [-5,805], scale: 0.48
    move_down 225
    text "Clone Systems Incident Report", size: 30, style: :bold, spacing: 4, align: :center
    move_down 20
    text @report_header, size: 19, style: :bold, spacing: 4, align: :center
    move_down 6
    text @report_time, size: 11, style: :bold, spacing: 2, align: :center
    move_down 50
    indent(238) { put_criteria_into_table }

    # create_summary if report.include_summary
    @incidents.each do |incident|
      start_new_page
      text "Name: #{incident.incident_name}", size: 15, style: :bold, spacing: 4, align: :left
      stroke_horizontal_line bounds.left, bounds.right
      move_down 20
      text "Status: ", size: 10, style: :bold, spacing: 4, align: :left
      text "#{incident.status}", size: 10, style: :normal, spacing: 4, align: :left
      move_down 20
      text "Description: ", size: 10, style: :bold, spacing: 4, align: :left
      text "#{incident.incident_description}", size: 10, style: :normal, spacing: 4, align: :left
      move_down 20
      text "Resolution: ", size: 10, style: :bold, spacing: 4, align: :left
      text "#{incident.incident_resolution}", size: 10, style: :normal, spacing: 4, align: :left
      start_new_page
      text "Events for incident: #{incident.incident_name}", size: 15, style: :bold, spacing: 4, align: :left
      move_down 10
      if @max_exceeded
        stroke_horizontal_line bounds.left, bounds.right
        move_down 10
        indent(15) do
          text "There were #{incidents_count} matching Incidents. This exceeds the maximum of #{@max_incidents_per_pdf} per PDF. Only #{@max_incidents_per_pdf} will be shown in this PDF.", size: 10, style: :bold, spacing: 4, align: :left
        end
        move_down 7
        stroke_horizontal_line bounds.left, bounds.right
        move_down 10
      end
      put_events_into_table(incident.incident_events)
    end
    # note: always do this last so Prawn's "number_pages" will number every page:
    set_footer_for_every_page
  end

  def create_summary
    take_pulse(@user, @report.report_criteria[:relative_date_range])
    stroke_color "8d8d8d" # grey
    start_new_page
    text "Top Attackers", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @attackers.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      @attackers = @attackers.order('ipcnt DESC')
      chart_data = @attackers.map { |aip| aip.ipcnt }
      chart_labels = @attackers.map { |aip| aip.ip_source.to_s }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 40
      indent(200) { create_attackers_table }
    end
    start_new_page
    text "Top Targets", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @targets.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      @targets = @targets.order('ipcnt DESC')
      chart_data = @targets.map { |tip| tip.ipcnt }
      chart_labels = @targets.map { |tip| tip.ip_destination.to_s }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 20
      indent(200) { create_targets_table }
    end
    start_new_page
    text "Priorities", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @priorities.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      chart_data = @priorities.map { |p| p.priority_cnt }
      chart_labels = @priorities.map { |p| p.sig_priority }
      image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 20
      indent(200) { create_priorities_table }
    end
    start_new_page
    text "Top Events by Signature", size: 15, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 30
    if @events_by_signature.blank?
      text "none", size: 10, style: :bold, spacing: 4, align: :center
    else
      @events_by_signature = @events_by_signature.order('event_cnt DESC')
      chart_data = @events_by_signature.map { |ebs| ebs.event_cnt }
      chart_labels = @events_by_signature.map { |ebs| ebs.sig_name }
      # cls: signature names have bizarre characters in them which is bad for gcharts, so don't do:
      # image gchart_image("", chart_labels, chart_data), scale: 0.75
      move_down 20
      indent(200) { create_events_by_signature_table }
    end
    # note: the sql used to find the most active times is too slow, so this is disabled:
    # start_new_page
    # move_down 20
    # text "Most Active Times", size: 15, style: :bold, spacing: 4, align: :center
    # stroke_horizontal_line bounds.left, bounds.right
    # move_down 30
    # text "15 minute intervals with more than 10 events", size: 10, spacing: 4, align: :center
    # move_down 10
    # if @hot_times.blank?
    #   text "none", size: 10, style: :bold, spacing: 4, align: :center
    # else
    #   indent(200) { create_most_active_times_table }
    # end
  end

  def gchart_image(chart_title, chart_labels, chart_data)
    # note that the gem googlecharts generates something like this:
    # "http://chart.apis.google.com/chart?chco=FFF804,336699,339933,ff0000,cc99cc,cf5910&chf=bg,s,FFFFFF&chd=s:9JBBAA&chl=19.168.1.3|19.168.1.4|19.168.1.8|10.81.4.130|0.0.0.1|0.0.4.87&chtt=&cht=p3&chs=900x300&chxr=0,1561,1561"
    img = URI.parse(URI.encode(Gchart.pie_3d(data: chart_data, labels: chart_labels, size: @gchart_size, title: chart_title, theme: :thirty7signals))).to_s
    img = open(img)
  end

  # note: the sql used to find the most active times is too slow, so this is disabled:
  # def create_most_active_times_table
  #   atable =  [ ["count", "Most Active Times (UTC)"] ] + 
  #     @hot_times.map do |hot_time|
  #       s = hot_time.minute
  #       e = hot_time.minute + 15.minutes
  #       [hot_time.cnt, s.strftime("%l:%M") + ' - ' + e.strftime("%l:%M %P")]
  #     end
  #   table atable do
  #     self.header = true
  #     row(0).background_color = "5D829F"
  #     row(0).text_color = "FFFFFF"
  #     row(0).font_style = :bold
  #     self.row_colors = ["D4E1EF", "FFFFFF"]
  #     self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
  #     self.columns(0).align = :right
  #   end
  # end

  def create_attackers_table
    atable =  [ ["Count", "Top Attackers"] ] + @attackers.map { |aip| [aip.ipcnt, aip.ip_source.to_s] }
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 120
      self.column_widths = [45, 75]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def create_targets_table
    atable =  [ ["Count", "Top Targets"] ] + @targets.map { |tip| [tip.ipcnt, tip.ip_destination.to_s] }
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 120
      self.column_widths = [45, 75]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def create_priorities_table
    priority_table = @priorities.map { |p| [p.priority_cnt, p.sig_priority] }
    priority_table_flatten = priority_table.flatten
    priority_cnt = priority_table_flatten.columnize :columns => 2, :offset => 0
    sig_priority = priority_table_flatten.columnize :columns => 2, :offset => 1
    priority_table_updated = []
    i = 0
    sig_priority = sig_priority.map do |key|
      priority_table_updated << [ priority_cnt[i], set_priority_level(key) ]
      i = i+1
    end
    atable =  [ ["Count", "Priorities"] ] + priority_table_updated
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.width = 120
      self.column_widths = [45, 75]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def create_events_by_signature_table
    atable =  [ ["Count", "Top Events by Signature"] ] + @events_by_signature.map { |ebs| [ebs.event_cnt, ebs.sig_name] }
    table atable do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
      self.columns(0).align = :right
    end
  end

  def put_criteria_into_table
    criteria_table = @report.report_criteria.map do |key, value|
                        k = "Incident Status:"   if key == "incident_status"
                        k = "Priority:"          if key == "sig_priority"
                        if key == "sig_id"
                          k = "Signature:"
                          value = SignatureDetail.find(value).sig_name unless value.blank?
                        end
                        k = "Source IP:"         if key == "source_address"
                        k = "Source Port:"       if key == "source_port"
                        k = "Destination IP:"    if key == "destination_address"
                        k = "Destination Port:"  if key == "destination_port"
                        if key == "sensor_id"
                          k = "Sensor:"
                          value = Sensor.find(value).hostname unless value.blank?
                        end
                        k = "Date Range:"        if key == "relative_date_range"
                        k = "Begin Date:"        if key == "timestamp_gte"
                        k = "End Date:"          if key == "timestamp_lte"
                        [k, value]
                      end
    criteria_table = criteria_table.reject{ |k, value| value.strip.length == 0 }
    table criteria_table do
      self.header = false
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
    end
  end

  def put_events_into_table(events)
    events_table =  set_table_header_row +
                    events.map do |event|
                      [event.sig_priority, SignatureDetail.find(event.signature).sig_name,
                       event.source_ip_port, event.destination_ip_port,
                       event.hostname, event.timestamp.to_s
                      ]
                    end
    table events_table do
      self.header = true
      row(0).background_color = "5D829F"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      # comment the width attributes below to let prawn figure this stuff out:
      self.width = 585
      self.column_widths = [38, 154, 91, 91, 109, 102]
      self.row_colors = ["D4E1EF", "FFFFFF"]
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 1, borders: [:left, :right, :bottom], border_color: "D4E1EF"}
    end
  end

  def set_table_header_row
    [ ["Priority", "Signature", "Source", "Destination", "Sensor", "Timestamp"] ]
  end

  def set_title_for_every_page
    repeat :all do
      text_box @report_title, at: [5, (bounds.top + 20)], size: 10, style: :bold, align: :center
    end
  end

  def set_footer_for_every_page
    page_footer = "#{Time.now.utc.strftime("%a %b %d, %Y %I:%M:%S %P %Z")}"
    page_options = {:at => [5, 0],
                    :width => 400,
                    :page_filter => :all,
                    :align => :left,
                    :start_count_at => 1 }
    number_pages page_footer, page_options
    page_footer = "page <page> of <total>"
    page_options = {:at => [bounds.right - 405, 0],
                    :width => 400,
                    :page_filter => :all,
                    :align => :right,
                    :start_count_at => 1 }
    number_pages page_footer, page_options
  end

  def set_priority_level(key)
    if key == 1
      prrty = "High"
    elsif key == 2
      prrty = "Medium"
    elsif key == 3
      prrty = "Low"
    end
    return prrty
  end
end
