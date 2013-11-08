require 'ipaddr'

class Iphdr < ActiveRecord::Base
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # set_primary_keys [:sid, :cid]
  self.primary_keys = [:sid, :cid]

  belongs_to :sensor, foreign_key: :sid
  has_many :events, foreign_key: [:sid, :cid]
  # FIXME cls: there may be other valid opt_proto codes for Iphdr:
  # has_many :opts, foreign_key: [:sid, :cid], conditions: {opt_proto: 0}
  has_many :opts, -> { where opt_proto: 0 }

  # usage:  iphdr_object.ip_source.to_s for ip_src as a string
  #         iphdr_object.ip_source.to_i for ip_src as a numeric
  composed_of :ip_source,
              :class_name => 'IPAddr',
              :mapping => %w(ip_src to_i),
              :constructor => Proc.new { |ip| IPAddr.new(ip, Socket::AF_INET) },
              :converter => Proc.new { |ip| ip.is_a?(Integer) ? IPAddr.new(ip, Socket::AF_INET) : IPAddr.new(ip.to_s) }

  # usage:  iphdr_object.ip_destination.to_s for ip_dst as a string
  #         iphdr_object.ip_destination.to_i for ip_dst as a numeric
  composed_of :ip_destination,
              :class_name => 'IPAddr',
              :mapping => %w(ip_dst to_i),
              :constructor => Proc.new { |ip| IPAddr.new(ip, Socket::AF_INET) },
              :converter => Proc.new { |ip| ip.is_a?(Integer) ? IPAddr.new(ip, Socket::AF_INET) : IPAddr.new(ip.to_s) }

  def self.is_valid?(ip)
    return true if ip.blank?
    IPAddr.new(ip, Socket::AF_INET).to_i
    true
  rescue Exception => e
    false
  end

  def self.to_numeric(ip)
    IPAddr.new(ip, Socket::AF_INET).to_i
  rescue Exception => e
    return e.message
  end

  def self.numeric?(object)
    return true if object.blank?
    true if Integer(object) rescue false
  end

  # meanings for ip_proto column in iphdr table:
  # function IPProto2str($ipproto_code) {
  #    switch($ipproto_code) {
  #       case 0:
  #           return "IP";
  #       case 1:
  #           return "ICMP";
  #       case 2:
  #           return "IGMP";
  #       case 4:
  #           return "IPIP tunnels";
  #       case 6:
  #           return "TCP";
  #       case 8:
  #           return "EGP";
  #       case 12:
  #           return "PUP";
  #       case  17:
  #           return "UDP";
  #       case 22:
  #           return "XNS UDP";
  #       case 29:
  #           return "SO TP Class 4";
  #       case 41:
  #           return "IPv6 header";
  #       case 43:
  #           return "IPv6 routing header";
  #       case 44:
  #           return "IPv6 fragmentation header";
  #       case 46: 
  #           return "RSVP";
  #       case 47:
  #           return "GRE";
  #       case 50: 
  #           return "IPSec ESP";
  #       case 51: 
  #           return "IPSec AH";
  #       case 58: 
  #           return "ICMPv6";
  #       case 59: 
  #           return "IPv6 no next header";
  #       case 60:
  #           return "IPv6 destination options";
  #       case 92:
  #           return "MTP";
  #       case 98:
  #           return "Encapsulation header";
  #       case 103: 
  #           return "PIM";
  #       case 108:
  #           return "COMP";
  #       case 255: 
  #           return "Raw IP";
  #       default:
  #           return $ipproto_code;
  #    }
  # } 
end
