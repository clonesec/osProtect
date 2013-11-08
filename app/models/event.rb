class Event < ActiveRecord::Base
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # alias_attribute :sid, 'event.sid'
  # alias_attribute :cid, 'event.cid'
  # set_primary_keys [:sid, :cid]
  self.primary_keys = [:sid, :cid]

  include RestrictEventsBasedOnUsersAccess # see app/models/concerns

  belongs_to :sensor, foreign_key: :sid
  belongs_to :iphdr, foreign_key: [:sid, :cid], :dependent => :destroy
  # note: the Signature table has been renamed to "signature_detail", coz there is a column
  #       in the Event table called signature ... so this resolves any confusion:
  has_one :signature_detail, :class_name => "SignatureDetail", :foreign_key => 'sig_id', :primary_key => 'signature'
  # note: the Data table has been renamed to Payload, coz "data" is a common/reserved word:
  has_one :payload, foreign_key: [:sid, :cid], :dependent => :destroy
  has_one :icmphdr, foreign_key: [:sid, :cid], :dependent => :destroy
  has_one :udphdr,  foreign_key: [:sid, :cid], :dependent => :destroy
  has_one :tcphdr,  foreign_key: [:sid, :cid], :dependent => :destroy

  def self.add_events_to_incident(incident_id, events, user)
    return nil if events.blank?
    incident = Incident.where(id: incident_id)
    incident = incident.any? ? incident.first : Incident.create(user_id: user.id, group_id: user.groups.first.id, events_added_count: 0)
    ActiveRecord::Base.transaction do
      events.each do |key, sid_cid_value|
        event = Event.includes(:sensor, :signature_detail, :iphdr, :tcphdr, :icmphdr, :udphdr, :payload).find(sid_cid_value)
        sc = sid_cid_value.split(',')
        # don't allow duplicate events in an incident:
        incident.events_rejected_count += 1 if IncidentEvent.where(incident_id: incident_id, sid: sc[0], cid: sc[1]).any?
        next if IncidentEvent.where(incident_id: incident_id, sid: sc[0], cid: sc[1]).any?
        incident_events_attributes = IncidentEvent.set_attributes(event)
        incident.incident_events.build(incident_events_attributes)
        incident.events_added_count += 1
      end
      incident.save(validate: false)
    end
    incident.incident_name = "Incident ##{incident.id}" if incident.incident_name.blank?
    incident.save(validate: false)
    incident || nil
  end

  def events
    @events
  end

  def key
    self.id.to_s
  end

  def key_as_array
    self.id.to_a
  end

  def key_with_underscore
    self.id.to_s.gsub(',', '_')
  end

  def priority
    self.signature_detail.sig_priority
  end

  def signature
    self.signature_detail.sig_name
  end

  def common_name_for_sensor
    if self.sensor.sensor_name.blank?
      cnfs = self.sensor.hostname # use the name from Snort
    else
      cnfs = self.sensor.sensor_name.name
    end
    cnfs = "?" if cnfs.blank?
    cnfs
  end

  def sensor_name
    self.sensor.hostname
  end

  def source_ip_port
    sip = self.iphdr.ip_source.to_s
    sip += ' : ' + self.tcphdr.tcp_sport.to_s unless no_tcphdr?
    sip += ' : ' + self.udphdr.udp_sport.to_s unless no_udphdr?
    sip
  end

  def destination_ip_port
    dip = self.iphdr.ip_destination.to_s
    dip += ' : ' + self.tcphdr.tcp_dport.to_s unless no_tcphdr?
    dip += ' : ' + self.udphdr.udp_dport.to_s unless no_udphdr?
    dip
  end

  private

  def no_tcphdr?
    self.tcphdr.blank?
  end

  def no_udphdr?
    self.udphdr.blank?
  end
end
