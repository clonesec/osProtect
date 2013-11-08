class CreateNotificationSignatureSections < ActiveRecord::Migration
  def change
    create_table :notification_signature_sections do |t|
      t.references  :notification
      t.string      :title
      t.text        :description
      t.text        :signature_ids
      t.timestamps
    end
    add_index :notification_signature_sections, :notification_id
  end
end
