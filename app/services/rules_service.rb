class RulesService
  attr_reader :errors, :file_path, :timeout, :local, :uri, :count, :results

  def initialize(rules_location)
    @rules_location = rules_location
    @folder = @rules_location.rules_folder.gsub(/\/+$/, '') # remove trailing slashes
    @file_path = ''
    @timeout = @rules_location.request_timeout.blank? ? 30000 : @rules_location.request_timeout
    @local = @rules_location.url_domain_ip.blank?
    @uri = ''
    @count = 0
    @errors = ''
    @results = []
  end

  def list_folder
    local_list_folder if @local
    remote_list_folder unless @local
  end

  def list_rules_in_file(file_name)
    local_list_rules_in_file(file_name) if @local
    remote_list_rules_in_file(file_name) unless @local
  end

  def write_rules_to_file(borrowed_file)
    local_write_rules_in_file(borrowed_file) if @local
    remote_write_rules_in_file(borrowed_file) unless @local
  end

  private

  def local_list_folder
    begin
      Dir.foreach(@folder) do |filename|
        full_file_path = File.join(@folder, filename)
        next if filename == ".." || filename == "."
        if File.extname(full_file_path) == ".rules"
          @count += 1
          @results << filename
        end
      end
      @results.sort!
    rescue Exception => e
      @errors << "#{e.message}"
    end
  end

  def remote_list_folder
    @uri = @rules_location.url_protocol + '://' + @rules_location.url_domain_ip + ':' + 
           @rules_location.url_port.to_s + '/' + @rules_location.list_folder_path
    params = {folder: @rules_location.rules_folder}
    tresponse = Typhoeus::Request.post(@uri, body: params, timeout: @timeout)
    unless tresponse.blank?
      if tresponse.code == 200
        tbody = JSON.parse(tresponse.body)
        @results = tbody['results']
        @count = tbody['count'].to_i unless tbody['count'].blank?
      elsif tresponse.code == 403
        tbody = JSON.parse(tresponse.body)
        @errors += tbody['errors']
      else
        @errors += "<br>return code: " + tresponse.return_code.to_s.gsub('_', ' ') unless tresponse.return_code.to_s.blank?
        @errors += "<br>response code: " + tresponse.response_code.to_s unless tresponse.response_code.to_s.blank?
      end
    end
  end

  def local_list_rules_in_file(file_name)
    begin
      @file_path = @rules_location.rules_folder.gsub(/\/+$/, '') + '/' + file_name
      @results = File.open(@file_path, "r").readlines # this keeps the linefeed "\n" for each line read
    rescue Exception => e
      @errors << "#{e.message}"
    end
  end

  def remote_list_rules_in_file(file_name)
    @uri = @rules_location.url_protocol + '://' + @rules_location.url_domain_ip + ':' + 
           @rules_location.url_port.to_s + '/' + @rules_location.list_rules_in_file_path
    @file_path = @rules_location.rules_folder.gsub(/\/+$/, '') + '/' + file_name
    file_path = CGI.escape(@file_path)
    params = {file: file_path}
    tresponse = Typhoeus::Request.post(@uri, body: params, timeout: @timeout)
    unless tresponse.blank?
      if tresponse.code == 200
        body = JSON.parse(tresponse.body)
        @results = body['results']
      elsif tresponse.code == 403
        body = JSON.parse(tresponse.body)
        @errors = body['errors']
      else
        @errors += "<br>return code: " + tresponse.return_code.to_s.gsub('_', ' ') unless tresponse.return_code.to_s.blank?
        @errors += "<br>response code: " + tresponse.response_code.to_s unless tresponse.response_code.to_s.blank?
      end
    end
  end

  def local_write_rules_in_file(borrowed)
    begin
      rules = Rule.select('rawtext').where(rules_location_id: borrowed.rules_location_id).order('linenum ASC').map {|line| line.rawtext}.join
      IO.binwrite(borrowed.file_path, rules)
      @results = borrowed.file_path
    rescue Exception => e
      @errors << "#{e.message}"
    end
  end

  def remote_write_rules_in_file(borrowed)
    rules = Rule.select('rawtext').where(rules_location_id: borrowed.rules_location_id).order('linenum ASC').map {|line| line.rawtext}.join
    @uri = @rules_location.url_protocol + '://' + @rules_location.url_domain_ip + ':' + 
           @rules_location.url_port.to_s + '/' + @rules_location.write_rules_to_file_path
    file_path = CGI.escape(borrowed.file_path)
    params = {file: file_path, rules: rules}
    tresponse = Typhoeus::Request.post(@uri, body: params, timeout: @timeout)
    if tresponse.blank?
      @errors << "Error: no response was received from the osProtect Rules API sentinel."
    else
      if tresponse.code == 200
        body = JSON.parse(tresponse.body)
        @results = CGI.unescape(body['results'])
      else
        body = JSON.parse(tresponse.body)
        @errors << body['errors']
      end
    end
  end
end