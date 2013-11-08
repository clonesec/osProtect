class CreatePdfs < ActiveRecord::Migration
  def change
    create_table :pdfs do |t|
      t.references  :user
      # pdf types:
      #   1 - EventsReport with optional summary(pulse) page ... EventsPdf
      #   2 - IncidentsReport with description+resolution and their events ... IncidentsPdf
      #   3 - EventsSearch, directly from the events page
      #   4 - Notifications
      t.integer     :pdf_type # 1, 2, 3, 4
      t.integer     :report_id
      t.string      :path_to_file
      t.string      :file_name
      t.text        :creation_criteria
      t.timestamps
    end
  end
end
