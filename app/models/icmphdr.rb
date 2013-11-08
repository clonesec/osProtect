class Icmphdr < ActiveRecord::Base
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # set_primary_keys [:sid, :cid]
  self.primary_keys = [:sid, :cid]

  belongs_to :sensor, :foreign_key => 'sid'
  # belongs_to :event, foreign_key: [:sid, :cid]


  # meanings for icmp_type column in icpmhdr table:
  # function ICMPType2str($icmp_type) {
  #   switch ($icmp_type) {
  #       case 0:                             /* ICMP_ECHOREPLY */
  #           return "Echo Reply";
  #       case 3:                             /* ICMP_DEST_UNREACH */
  #           return "Destination Unreachable";
  #       case 4:                             /* ICMP_SOURCE_QUENCH */
  #           return "Source Quench";
  #       case 5:                             /* ICMP_REDIRECT */
  #           return "Redirect";
  #       case 8:                             /* ICMP_ECHO */
  #           return "Echo Request";
  #       case 9:
  #           return "Router Advertisement";
  #       case 10:
  #           return "Router Solicitation"; 
  #       case 11:                            /* ICMP_TIME_EXCEEDED */
  #           return "Time Exceeded";
  #       case 12:                            /* ICMP_PARAMETERPROB */
  #           return "Parameter Problem";
  #       case 13:                            /* ICMP_TIMESTAMP */
  #           return "Timestamp Request";
  #       case 14:                            /* ICMP_TIMESTAMPREPLY */
  #           return "Timestamp Reply";
  #       case 15:                            /* ICMP_INFO_REQUEST */
  #           return "Information Request";
  #       case 16:                            /* ICMP_INFO_REPLY */
  #           return "Information Reply";
  #       case 17:                            /* ICMP_ADDRESS */
  #           return "Address Mask Request";
  #       case 18:                            /* ICMP_ADDRESSREPLY */
  #           return "Address Mask Reply";
  #       case 19:
  #           return "Reserved (security)";
  #       case 20:
  #           return "Reserved (robustness)";
  #       case 21:
  #           return "Reserved (robustness)";
  #       case 22:
  #           return "Reserved (robustness)";
  #       case 23:
  #           return "Reserved (robustness)";
  #       case 24:
  #           return "Reserved (robustness)";
  #       case 25:
  #           return "Reserved (robustness)";
  #       case 26:
  #           return "Reserved (robustness)";
  #       case 27:
  #           return "Reserved (robustness)";
  #       case 28:
  #           return "Reserved (robustness)";
  #       case 29:
  #           return "Reserved (robustness)";
  #       case 30:
  #           return "Traceroute";
  #       case 31:
  #           return "Datagram Conversion Error";
  #       case 32:
  #           return "Mobile Host Redirect";
  #       case 33:
  #           return "IPv6 Where-Are-You";
  #       case 34:
  #           return "IPv6 I-Am-Here";
  #       case 35:
  #           return "Mobile Registration Request";
  #       case 36:
  #           return "Mobile Registration Reply";
  #       case 37:
  #           return "Domain Name Request";
  #       case 38:
  #           return "Domain Name Reply";
  #       case 39:
  #           return "SKIP";
  #       case 40:
  #           return "Photuris";
  #       default:
  #           return $icmp_type;
  #   }
  # }
end
