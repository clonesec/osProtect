class AddEventsInEmailToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :events_in_email, :boolean, default: false
  end
end
