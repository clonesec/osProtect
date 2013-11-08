class AddIntroductionIncludeChartsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :include_events, :boolean, default: false
    add_column :reports, :introduction, :text
  end
end
