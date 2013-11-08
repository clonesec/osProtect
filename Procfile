# cls: only for dev/test environments:
web: bundle exec thin start -p 3000
worker: bundle exec rake resque:work QUEUE=*
scheduler: bundle exec rake resque:scheduler
