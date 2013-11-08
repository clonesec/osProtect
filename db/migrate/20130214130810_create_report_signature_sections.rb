class CreateReportSignatureSections < ActiveRecord::Migration
  def change
    create_table :report_signature_sections do |t|
      t.references  :report
      t.string      :title
      t.text        :description
      t.text        :signature_ids
      t.timestamps
    end
    add_index :report_signature_sections, :report_id
  end
end
