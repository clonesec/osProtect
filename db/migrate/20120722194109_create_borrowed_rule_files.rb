class CreateBorrowedRuleFiles < ActiveRecord::Migration
  def change
    create_table :borrowed_rule_files do |t|
      t.references  :user
      t.references  :rules_location
      t.string      :file_name
      t.string      :file_path
      t.timestamps
    end
    add_index :borrowed_rule_files, :user_id
    add_index :borrowed_rule_files, :rules_location_id
    add_index :borrowed_rule_files, :file_name
  end
end
