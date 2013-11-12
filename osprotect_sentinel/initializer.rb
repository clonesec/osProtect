require 'sinatra'

# sudo nano /etc/environment and ~/.bashrc then add:
# RACK_ENV=production
env = ENV["RACK_ENV"]
# or:
# set :environment, :production

settings_yml_load_file = YAML::load(File.open('config/settings.yml'))
if settings_yml_load_file # must be a Hash
  settings_yml = settings_yml_load_file['production']
  if settings_yml.nil?
    set "allow_requests_from_ip", "127.0.0.1"
  else
    settings_yml.each do |key, value|
      set key, value # create "settings" ... see: http://www.sinatrarb.com/configuration.html:
    end
  end
else
  set "allow_requests_from_ip", "127.0.0.1"
end
set allow_requests_from_ip, "127.0.0.1" if settings.allow_requests_from_ip.empty?

