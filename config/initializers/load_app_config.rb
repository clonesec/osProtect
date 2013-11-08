app_config = YAML.load_file(Rails.root.join('config', 'app_config.yml'))
if app_config.nil? || app_config[Rails.env].nil?
  # do the following so we don't have ugly 'if..else's in our code:
  APP_CONFIG = Hash.new
  APP_CONFIG[:web_server] = 'unknown'
  APP_CONFIG[:host] = 'unknown'
  APP_CONFIG[:version] = 'unknown'
  APP_CONFIG[:show_versions_and_limits] = false
  APP_CONFIG[:max_events_per_pdf] = 0
  APP_CONFIG[:emails_from] = "do.not.reply@unknown.fix.me"
  APP_CONFIG[:per_page] = 12
  APP_CONFIG[:can_do_notifications] = false
  APP_CONFIG[:max_events_that_can_be_copied_to_incidents_for_each_notification] = 0
  APP_CONFIG[:max_events_per_pdf] = 0
  APP_CONFIG[:can_do_reports] = false
  APP_CONFIG[:can_daily_report] = false
  APP_CONFIG[:can_weekly_report] = false
  APP_CONFIG[:can_monthly_report] = false
else
  # 'config/app_config.yml' was found so let's try to use those settings:
  APP_CONFIG = app_config[Rails.env].symbolize_keys
  APP_CONFIG[:per_page] = 12 if APP_CONFIG[:per_page].blank?
  APP_CONFIG[:per_page] = 50 if APP_CONFIG[:per_page] > 50 # max is 50
  # sensible default if your server's memory is 2GB, adjust accordingly:
  APP_CONFIG[:max_events_per_pdf] = 1000 if APP_CONFIG[:max_events_per_pdf].blank?
end
