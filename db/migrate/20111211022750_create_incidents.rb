class CreateIncidents < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.integer     :group_id
      t.integer     :user_id
      t.string      :incident_name
      t.string      :status,              default: 'pending'
      t.text        :incident_description
      t.text        :incident_resolution
      t.timestamps
    end
  end
end
