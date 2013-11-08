class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.references  :rules_location
      t.integer     :linenum
      t.text        :rawtext
      t.timestamps
    end
    add_index :rules, :rules_location_id
  end
end
