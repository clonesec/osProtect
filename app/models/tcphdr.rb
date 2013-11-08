class Tcphdr < ActiveRecord::Base
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # set_primary_keys [:sid, :cid]
  self.primary_keys = [:sid, :cid]

  belongs_to :sensor, :foreign_key => 'sid'
  # belongs_to :event, foreign_key: [:sid, :cid]
  # has_many :opts, foreign_key: [:sid, :cid], conditions: {opt_proto: 6}
  has_many :opts, -> { where opt_proto: 6 }, foreign_key: [:sid, :cid]

  # TODO see BASE base_qry_alert.php for tcp_flags code
end
