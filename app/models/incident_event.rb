class IncidentEvent < ActiveRecord::Base
  belongs_to :incident

  # TODO serialize opt's for tcphdr!!

  serialize :ref_tags_and_system_names
  # note: to read the keys/values: some_incident_event.ref_tags_and_system_names.each {|k,v| puts "#{k}=#{v}" }

  def self.set_attributes(event)
    # since the db tables for Snort/whatever may be truncated/deleted/pruned from time to time,
    # the combination of "timestamp + sid + cid" makes an Event unique ... i.e. the "sid + cid"
    # combination may be reused, so also including a timestamp will keep it unique.
    a = event.attributes
    a.merge!(vseq: Schema.first.vseq) unless Schema.first.nil?
    a.merge!(ctime: Schema.first.ctime) unless Schema.first.nil?
    a.merge!(event.sensor.attributes) unless event.sensor.nil?
    a.merge!(event.sensor.sensor_detail.attributes) unless event.sensor.sensor_detail.nil?
    a.merge!(event.sensor.sensor_encoding.attributes) unless event.sensor.sensor_encoding.nil?
    a.merge!(event.signature_detail.attributes) unless event.signature_detail.nil?
    a.merge!(event.signature_detail.signature_class.attributes) unless event.signature_detail.signature_class.nil?
    unless event.signature_detail.signature_references.nil?
      ref_tags_and_system_names = {}
      event.signature_detail.signature_references.each do |sr|
        sr.references.each do |refs|
          ref_tags_and_system_names[refs.ref_tag] = refs.reference_system.ref_system_name
        end
      end
      a.merge!(ref_tags_and_system_names: ref_tags_and_system_names)
    end
    unless event.iphdr.nil?
      a.merge!(event.iphdr.attributes)
      a.merge!(ip_source: event.iphdr.ip_source.to_s)
      a.merge!(ip_destination: event.iphdr.ip_destination.to_s)
    end
    a.merge!(event.tcphdr.attributes) unless event.tcphdr.nil?
    a.merge!(event.icmphdr.attributes) unless event.icmphdr.nil?
    a.merge!(event.udphdr.attributes) unless event.udphdr.nil?
    a.merge!(event.payload.attributes) unless event.payload.nil?
    # cls: Dear Snort, please get rid of these ancient composite primary keys ... headaches be gone!
    a.delete_if {|k, v| k.is_a?(CompositePrimaryKeys::CompositeKeys) }
    a
  end

  def source_ip_port
    sip = self.ip_source
    sip += ' : ' + self.tcp_sport.to_s unless tcp_sport.blank?
    sip += ' : ' + self.udp_sport.to_s unless udp_sport.blank?
    sip
  end

  def destination_ip_port
    dip = self.ip_destination
    dip += ' : ' + self.tcp_dport.to_s unless tcp_dport.blank?
    dip += ' : ' + self.udp_dport.to_s unless udp_dport.blank?
    dip
  end
end
