class Udphdr < ActiveRecord::Base
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # set_primary_keys [:sid, :cid]
  self.primary_keys = [:sid, :cid]

  belongs_to :sensor, :foreign_key => 'sid'
  # belongs_to :event, foreign_key: [:sid, :cid]
end
