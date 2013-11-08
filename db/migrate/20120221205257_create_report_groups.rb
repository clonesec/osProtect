class CreateReportGroups < ActiveRecord::Migration
  def change
    create_table :report_groups do |t|
      t.references :report
      t.references :group
      t.timestamps
    end
    add_index :report_groups, :report_id
    add_index :report_groups, :group_id
  end
end
