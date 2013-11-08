class CreateSensorNames < ActiveRecord::Migration
  def change
    create_table :sensor_names do |t|
      t.references  :sensor
      t.string      :name
      t.timestamps
    end
    add_index :sensor_names, :sensor_id
  end
end
