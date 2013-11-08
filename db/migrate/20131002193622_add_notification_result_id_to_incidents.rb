class AddNotificationResultIdToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :notification_id, :integer
  end
end
