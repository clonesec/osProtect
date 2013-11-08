class ReportGroup < ActiveRecord::Base
  belongs_to :report
  belongs_to :group
end
