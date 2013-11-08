class AdminRestriction
  # note: this is called for every request to the Resque web server:
  def matches?(request)
    # note: when this method returns "false" rails show a bad route error, instead of access denied.
    # Nov 2013: in Rails 4 this doesn't work coz it's nil:
    # auth_token = request.env['rack.request.cookie_hash']['auth_token']
    return false unless (auth_token_cookie = request.cookies['auth_token'])
    user = User.find_by(auth_token: auth_token_cookie)
    # puts "\n#{Time.now.utc}"
    # puts "auth_token_cookie=#{auth_token_cookie.inspect}"
    # puts "user && user.role?(:admin)=#{(user && user.role?(:admin)).inspect}\nuser=#{user.inspect}"
    # puts "user=#{user.inspect}"
    user && user.role?(:admin)
  end
end

OsProtect::Application.routes.draw do
  mount Resque::Server, :at => '/resque', :constraints => AdminRestriction.new

  resources :sessions
  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"

  resources :password_resets

  resources :sensors, :only => [:index, :edit, :update]

  get "pulse" => "dashboard#index", :as => "pulse"
  get "user_setup_required" => "dashboard#user_setup_required", :as => "user_setup_required"

  resources :incidents
  resources :incident_events, :only => [:destroy]
  delete "destroy_multiple_incidents" => "incidents#destroy_multiple", :as => "destroy_multiple_incidents"

  resources :users

  resources :groups

  resources :notifications

  resources :reports
  get "report_listing_events" => "reports#events_listing", :as => "report_listing_events"
  get "reports_pdf" => "reports#create_pdf", :as => "reports_pdf"

  resources :pdfs, :only => [:index, :show, :destroy]

  resources :rules_locations
  resources :rules
  get "return_rule_file" => "rules#return_rule_file", :as => "return_rule_file"
  get "cancel_rule_file" => "rules#cancel_rule_file", :as => "cancel_rule_file"

  get "info"      => "sentinel#info",     :as => "info"
  get "browse"    => "sentinel#browse",   :as => "browse"
  post "search"   => "sentinel#search",   :as => "search"
  post "groupby"  => "sentinel#groupby",  :as => "groupby"

  resources :events, :only => [:index, :show, :create, :create_pdf]
  get "home" => "events#index", :as => "home"
  post "events_pdf" => "events#create_pdf", :as => "events_pdf"

  root :to => "dashboard#index"
end
