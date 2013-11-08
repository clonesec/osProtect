class AddNotificationIdToPdf < ActiveRecord::Migration
  def change
    add_column :pdfs, :notification_id, :integer
  end
end
