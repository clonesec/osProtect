class NotificationSignatureSection < ActiveRecord::Base
  belongs_to :notification, inverse_of: :notification_signature_sections
  serialize :signature_ids, Array
end
