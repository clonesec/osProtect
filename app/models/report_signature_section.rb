class ReportSignatureSection < ActiveRecord::Base
  belongs_to :report, inverse_of: :report_signature_sections
  serialize :signature_ids, Array
end
