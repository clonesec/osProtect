class NotificationsPdf < Prawn::Document
  include DateRanges
  include PulseTopTens

  def initialize(user, notification, report_title, report_header, report_time, max_exceeded, max_events_per_pdf, events_count, events)
    return # Nov 2013: deprecated due to the possiblity of attackers creating a large number of PDFs
    super(top_margin: 30, left_margin: 5, right_margin: 5, font: "Helvetica", page_size: "A4", page_layout: :portrait)
    self.font_size = 8
    @user = user
    @notification = notification
    @report_title = report_title
    @report_header = report_header
    @report_time = report_time
    @max_exceeded = max_exceeded
    @max_events_per_pdf = max_events_per_pdf
    @events_count = events_count
    @events = events

    @coverbg = "app/assets/images/osProtect-background.jpg"
    # set_title_for_every_page
    image @coverbg, :at => [-5,805], scale: 0.48
    move_down 225
    text "Notification Report", size: 30, style: :bold, spacing: 4, align: :center
    move_down 20
    text @report_header, size: 19, style: :bold, spacing: 4, align: :center
    move_down 6
    text @report_time, size: 11, style: :bold, spacing: 2, align: :center
    move_down 50
    indent(238) { put_criteria_into_table }

    start_new_page
    text "Table of Contents", size: 20, style: :bold, spacing: 4, align: :center
    stroke_horizontal_line bounds.left, bounds.right
    move_down 20
    toc_num = 1
    section = 1
    move_down 5
    signature_section_start = section
    if @notification.notification_signature_sections.any?
      text "<link anchor='section#{section}'>#{toc_num}. Report Sections</link>", :inline_format=>true, size: 12
      toc_num += 1
      move_down 3
      indent(15) do
        @notification.notification_signature_sections.each_with_index do |notification_section, x|
          title = notification_section.title.blank? ? 'Untitled Report Section' : notification_section.title
          text "<link anchor='section#{section}'>(#{x+1}) #{title}</link>", :inline_format=>true, size: 12
          section += 1
          move_down 3
        end
      end
      move_down 2
    end

    if @notification.events_in_email
      all_events_section = section
      text "<link anchor='section#{all_events_section}'>#{toc_num}. Events</link>", :inline_format=>true, size: 12
    end

    # Signature Sections:
    if @notification.notification_signature_sections.any?
      section = signature_section_start
      @notification.notification_signature_sections.each_with_index do |notification_section, x|
        start_new_page
        add_dest("section#{section}", dest_fit_horizontally(cursor, page.dictionary))
        section += 1
        title = notification_section.title.blank? ? "Untitled Report Section" : notification_section.title
        text title, size: 20, style: :bold, spacing: 4, align: :center
        stroke_horizontal_line bounds.left, bounds.right
        move_down 20
        unless notification_section.description.blank?
          text 'Description:', size: 12, spacing: 4, align: :left
          move_down 7
          text notification_section.description, size: 9, align: :left
          move_down 15
        end
        if notification_section.signature_ids.blank?
          stroke_horizontal_line bounds.left, bounds.right
          move_down 10
          indent(15) do
            text "No signatures selected for this section.", size: 10, style: :bold, spacing: 4, align: :left
          end
          move_down 7
          stroke_horizontal_line bounds.left, bounds.right
        else
          events = @events.where("signature.sig_id IN (?)", notification_section.signature_ids)
          put_into_table(events)
        end
        move_down 10
      end
    end

    if @notification.events_in_email
      start_new_page
      add_dest("section#{all_events_section}", dest_fit_horizontally(cursor, page.dictionary))
      text "Events", size: 15, style: :bold, spacing: 4, align: :center
      move_down 10
      @detailed_view_text = "The events table below shows all events along with the details related to each event. By utilizing the information in the table below a security analyst will be able to see traffic flow information such as source and destination IP addresses and ports numbers related to each event."
      text @detailed_view_text, size: 9, align: :left
      move_down 15
      put_into_table(@events) # show all matching events including matching signatures
      move_down 10
      if @max_exceeded
        stroke_horizontal_line bounds.left, bounds.right
        move_down 10
        indent(15) do
          text "There were #{events_count} matching Events. This exceeds the maximum of #{@max_events_per_pdf} per PDF. Only #{@max_events_per_pdf} will be shown in this PDF.", size: 10, style: :bold, spacing: 4, align: :left
        end
        move_down 7
        stroke_horizontal_line bounds.left, bounds.right
        move_down 10
      end
    end

    # note: always do this last so Prawn's "number_pages" will number every page:
    set_footer_for_every_page
  end

  def put_criteria_into_table
    criteria_table = @notification.notify_criteria.map do |key, value|
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
      [k, value] unless k.blank? || value.blank?
    end
    # criteria_table = criteria_table.reject{ |k, value| value.strip.length == 0 }
    criteria_table = criteria_table.reject{ |k, value| k.blank? || value.blank? }
    table criteria_table do
      self.header = false
      self.cell_style = {overflow: :shrink_to_fit, min_font_size: 8, border_width: 0}
    end
  end

  def put_into_table(events)
    events_table =  set_table_header_row + 
                    events.map do |event|
                      [event.priority, event.signature, event.source_ip_port, event.destination_ip_port, event.sensor_name, event.timestamp.to_s]
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
end
