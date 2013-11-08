class AddNoEventsYesterdayNotificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :no_events_yesterday_notification, :boolean, default: false
  end
end
