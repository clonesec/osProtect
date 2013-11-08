class AddIndexesToIncidentEvents < ActiveRecord::Migration
  def change
    add_index "incident_events", ["signature"],    :name => "ie_signature_idx"
    add_index "incident_events", ["timestamp"],    :name => "ie_timestamp_idx"
    add_index "incident_events", ["ip_dst"],       :name => "ie_ip_dst_idx"
    add_index "incident_events", ["ip_src"],       :name => "ie_ip_src_idx"
    add_index "incident_events", ["icmp_type"],    :name => "ie_icmp_type_idx"
    add_index "incident_events", ["tcp_sport"],    :name => "ie_tcp_sport_idx"
    add_index "incident_events", ["tcp_dport"],    :name => "ie_tcp_dport_idx"
    add_index "incident_events", ["tcp_flags"],    :name => "ie_tcp_flags_idx"
    add_index "incident_events", ["udp_sport"],    :name => "ie_udp_sport_idx"
    add_index "incident_events", ["udp_dport"],    :name => "ie_udp_dport_idx"
  end
end
