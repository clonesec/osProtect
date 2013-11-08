class Opt < ActiveRecord::Base
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # set_primary_keys :sid, :cid
  self.primary_keys = [:sid, :cid]

  belongs_to :sensor, foreign_key: :sid
  belongs_to :iphdr, foreign_key: [:sid, :cid]
  belongs_to :tcphdr, foreign_key: [:sid, :cid]

  # TODO tcp options decoding:
  # o=Opt.where(optid: 2).find(1,21)
  # o.opt_data.unpack('H*').first

  # meanings for opt_code column in opt table when opt_proto=6 (TCP):
  # function TCPOption2str($tcpopt_code) {
  #   /* per RFC 1072, 1323, 1644 */
  #    switch($tcpopt_code) {
  #       case 2:                  /* TCPOPT_MAXSEG - maximum segment*/ 
  #           return "(2) MSS";
  #       case 0:                  /* TCPOPT_EOL */
  #           return "(0) EOL";
  #       case 1:                  /* TCPOPT_NOP */
  #           return "(1) NOP";
  #       case 3:                  /* TCPOPT_WSCALE (rfc1072)- window scale factor */
  #           return "(3) WS";
  #       case 5:                  /* TCPOPT_SACK (rfc1072)- selective ACK */
  #           return "(5) SACK";
  #       case 4:                  /* TCPOPT_SACKOK (rfc1072)- selective ACK OK */
  #           return "(4) SACKOK";
  #       case 6:                  /* TCPOPT_ECHO (rfc1072)- echo */
  #           return "(6) Echo";
  #       case 7:                  /* TCPOPT_ECHOREPLY (rfc1072)- echo reply */
  #           return "(7) Echo Reply";
  #       case 8:                  /* TCPOPT_TIMESTAMP (rfc1323)- timestamps */
  #           return "(8) TS";
  #       case 9:                  /* RFC1693 */
  #           return "(9) Partial Order Connection Permitted";
  #       case 10:                  /* RFC1693 */ 
  #           return "(10) Partial Order Service Profile";
  #       case 11:                 /* TCPOPT_CC (rfc1644)- CC options */
  #           return "(11) CC";
  #       case 12:                 /* TCPOPT_CCNEW (rfc1644)- CC options */
  #           return "(12) CCNEW";
  #       case 13:                 /* TCPOPT_CCECHO (rfc1644)- CC options */
  #           return "(13) CCECHO";
  #       case 14:                 /* RFC1146 */
  #           return "(14) TCP Alternate Checksum Request";
  #       case 15:                 /* RFC1146 */
  #           return "(15) TCP Alternate Checksum Data";
  #       case 16:
  #           return "(16) Skeeter";
  #       case 17:
  #           return "(17) Bubba";
  #       case 18:                 /* Subbu and Monroe */
  #           return "(18) Trailer Checksum Option";
  #       case 19:                 /* Subbu and Monroe */
  #           return "(19) MD5 Signature";
  #       case 20:                 /* Scott */
  #           return "(20) SCPS Capabilities";
  #       case 21:                /* Scott */
  #           return "(21) Selective Negative Acknowledgements";
  #       case 22:                /* Scott */
  #           return "(22) Record Boundaries";
  #       case 23:                /* Scott */
  #           return "(23) Corruption Experienced";
  #       case 24:                /* Sukonnik */
  #           return "(24) SNAP";
  #       case 25:
  #           return "(25) Unassigned";
  #       case 26:                /* Bellovin */
  #           return "(26) TCP Compression Filter";
  #       default:
  #           return $tcpopt_code;
  #    }
  # }

  # meanings for opt_code column in opt table when opt_proto=0 (IP):
  # function IPOption2str($ipopt_code) {
  #    switch($ipopt_code) {
  #       case 7:              /* IPOPT_RR */
  #           return "RR";
  #       case 0:              /* IPOPT_EOL */
  #           return "EOL";
  #       case 1:              /* IPOPT_NOP */
  #           return "NOP";
  #       case 0x44:           /* IPOPT_TS */
  #           return "TS";
  #       case 0x82:           /* IPOPT_SECURITY */
  #           return "SEC";
  #       case 0x83:           /* IPOPT_LSRR */
  #           return "LSRR";
  #       case 0x84:           /* IPOPT_LSRR_E */
  #           return "LSRR_E";
  #       case 0x88:           /* IPOPT_SATID */
  #           return "SID";
  #       case 0x89:           /* IPOPT_SSRR */
  #           return "SSRR";
  #   }
  # }
end