class AddNameDescriptionToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :name, :string
    add_column :notifications, :description, :text
  end
end
