class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.text :debug_msg
      t.timestamps
    end
  end
end
