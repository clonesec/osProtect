class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references  :user
      t.string      :email
      t.boolean     :run_status, default: false # enabled or disabled
      t.text        :notify_criteria
      t.text        :notify_criteria_as_string # used to ensure this notification is not a duplicate (uniqueness)
      t.timestamps
    end
    add_index :notifications, :user_id
  end
end
