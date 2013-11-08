class CreateGroupSensors < ActiveRecord::Migration
  def change
    create_table :group_sensors do |t|
      t.references  :group
      t.references  :sensor
      t.timestamps
    end
    add_index :group_sensors, :group_id
    add_index :group_sensors, :sensor_id
  end
end
