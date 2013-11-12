# require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'

count = 0
results = []
errors = ""
forbidden = true

before do
  count = 0
  results = []
  errors = ""
  forbidden = false if settings.allow_requests_from_ip == request.ip
  if forbidden
    status 403 # 'Forbidden' see: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    errors = "#{request.ip} ?"
  end
  # note: now we 'pass' through to the matching request url below, so let's handle forbidden there
end

post '/info' do
  return {errors: errors}.to_json if forbidden
  begin
    mem = %x(free -lm)
    disk = %x(df -h)
    uptime = %x(uptime)
    return {mem: mem, disk: disk, uptime: uptime}.to_json
  rescue Exception => e
    puts "\nweb.rb: get '/info' :"
    puts "error=#{e.inspect}\n"
    puts "backtrace=#{e.backtrace.inspect}\n"
    errors << "error=#{e.message}\n"
    errors << "backtrace=#{e.backtrace.inspect}\n"
    status 422
    return {errors: errors, mem: '', disk: '', uptime: ''}.to_json
  end
end

post '/list_folder' do
  return {errors: errors}.to_json if forbidden
  # curl -X POST -d "folder=/usr/local/snort/rules" http://appsudo.com:8500/list_folder
  # curl -X POST -d "folder=/home/cleesmith/apps/osprotect_sentinel/rules/snort/rules" http://appsudo.com:8500/list_folder
  content_type :json
  errors = ""
  started = Time.now
  begin
    if params['folder'].nil? || params['folder'].empty?
      status 422
      return {errors: errors, elapsed: (Time.now - started), count: 0, results: []}.to_json
    end
    folder = params['folder'].gsub(/\/+$/, '') # remove trailing slashes
    count = 0
    files = []
    Dir.foreach(folder) do |filename|
      full_file_path = File.join(folder, filename)
      next if filename == ".." || filename == "."
      # if File.directory?(full_file_path)
      # end
      if File.extname(full_file_path) == ".rules"
        count += 1
        files << filename
      end
    end
    return {errors: errors, elapsed: (Time.now - started), count: count, results: files.sort}.to_json
  rescue Exception => e
    puts "\nweb.rb: post '/list_folder' :"
    puts "error=#{e.inspect}\n"
    errors << "error=#{e.message}\n"
    errors << "backtrace=#{e.backtrace.inspect}\n"
    status 422
    return {errors: errors, elapsed: (Time.now - started), count: 0, results: []}.to_json
  end
end

post '/list_rules_in_file' do
  return {errors: errors}.to_json if forbidden
  # curl -X POST -d "file=/home/cleesmith/apps/osprotect_sentinel/rules/snort/rules/cls_icmp.rules" http://appsudo.com:8500/list_rules_in_file
  content_type :json
  file_name = CGI.unescape(params['file'])
  started = Time.now
  begin
    if file_name.nil? || file_name.empty?
      status 422
      return {errors: errors, elapsed: (Time.now - started), count: 0, results: []}.to_json
    end
    rules = File.open(file_name, "r").readlines # this keeps the linefeed "\n" for each line read
    return {errors: errors, elapsed: (Time.now - started), count: count, results: rules}.to_json
  rescue Exception => e
    puts "\nweb.rb: post '/list_rules_in_file' :"
    puts "error=#{e.inspect}\n"
    errors << "error=#{e.message}\n"
    errors << "backtrace=#{e.backtrace.inspect}\n"
    status 422
    return {errors: errors, elapsed: (Time.now - started), count: 0, results: []}.to_json
  end
end

post '/write_rules_to_file' do
  return {errors: errors}.to_json if forbidden
  # curl -X POST -d "file=/home/cleesmith/apps/osprotect_sentinel/cls.txt" http://appsudo.com:8500/write_rules_to_file
  content_type :json
  file_name = CGI.unescape(params['file'])
  started = Time.now
  if file_name.nil? || file_name.empty?
    puts "\nweb.rb: post '/write_rules_to_file' :"
    puts "file_name is nil or empty!\n"
    errors << "file_name is nil or empty!\n"
    status 422
    return {errors: errors, elapsed: (Time.now - started), count: 0, results: []}.to_json
  end
  count = 0
  results = ""
  file = params['file']
  begin
    IO.binwrite(file_name, params['rules'])
    # rules = params['rules']
    # update_file = File.new(file, "w")
    # if rules.nil?
    #   update_file.write("# no rules written")
    #   # count += 1
    # else
    #   # rules.each do |ignore_linenum_key, rule_text|
    #   # rules.each do |rule_text|
    #   #   update_file.write(rule_text.to_s.gsub("\n", "") + "\n")
    #   #   count += 1
    #   # end
    #   update_file.write(rules)
    # end
    results = "#{file}"
  rescue Exception => e
    puts "\nweb.rb: post '/write_rules_to_file' :"
    puts "error=#{e.inspect}\n"
    puts "backtrace=#{e.backtrace.inspect}\n"
    errors << "error=#{e.message}\n"
    # errors << "backtrace=#{e.backtrace.inspect}\n" # <-- is too big for a rails flash message!
    status 422
  ensure
    # update_file.close unless update_file.nil?
    return {errors: errors, elapsed: (Time.now - started), count: count, results: results}.to_json
  end
end
