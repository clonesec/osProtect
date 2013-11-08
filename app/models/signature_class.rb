class SignatureClass < ActiveRecord::Base
  self.table_name = 'sig_class'
  self.pluralize_table_names = false
  # set_primary_key 'sig_class_id' # deprecated in rails 3.2.0, instead do:
  self.primary_key = 'sig_class_id'
  alias_attribute :id, :sig_class_id

  has_many :signature_details, :foreign_key => 'sig_class_id'
end
