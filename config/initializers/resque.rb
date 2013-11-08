require 'resque'
require 'resque_scheduler'
require 'resque_scheduler/server'

# FIXME figure out how to use a unix socket instead of localhost:port ...
#       maybe this: (see: http://stackoverflow.com/questions/7010668/is-it-possible-to-start-resque-web-listening-to-a-redis-socket)
#         in RAILS_ROOT/config/resque.yml:
#         development: /tmp/redis.sock
#
#         in RAILS_ROOT/config/initializers/resque.rb:
#         rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
#         rails_env = ENV['RAILS_ENV'] || 'development'
#         resque_config = YAML.load_file(rails_root + '/config/resque.yml')
#         if resque_config[rails_env] =~ /^\// # using unix socket
#             Resque.redis = Redis.new(:path => resque_config[rails_env])
#         else 
#            Resque.redis = resque_config[rails_env]
#         end
#
# NOTE the above only applies to resque workers, as the resque-web server will still use localhost:port !!!!!!!!!!

# this must be before the YAML.load_file's:
# Resque::Scheduler.dynamic = true

config = YAML.load_file(Rails.root.join('config', 'resque.yml'))
schedule = YAML.load_file(Rails.root.join('config', 'schedule.yml'))

# configure redis connection
Resque.redis = config[Rails.env]

# configure the schedule
Resque.schedule = schedule

# set a custom namespace for redis (optional)
# Resque.redis.namespace = "resque:osprotect"

# Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }