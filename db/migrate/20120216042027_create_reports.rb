class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer     :user_id
      t.boolean     :for_all_users, default: false # true=created by an admin for all users
      # report types:
      #   1 - EventsReport with optional summary(pulse) page ... EventsPdf
      #   2 - IncidentsReport with description+resolution and their events ... IncidentsPdf
      t.integer     :report_type, default: 1
      t.boolean     :run_status, default: false # enabled or disabled
      # n=no, d=daily(previous day), w=weekly(previous week), m=monthly(previous month):
      t.string      :auto_run_at, limit: 1, default: 'n'
      t.boolean     :include_summary, default: false
      t.string      :name
      t.text        :report_criteria
      t.string      :report_criteria_as_string
      t.timestamps
    end
  end
end
