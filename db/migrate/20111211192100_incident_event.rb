class IncidentEvent < ActiveRecord::Migration
# mysql integer types:
# :limit      numeric type  size      Signed (negative) values                      Unsigned (non-negative) values
# ==========  ============  =======   ========================                      ===============================
# 1           tinyint       1 byte    -128 to 127                                   0 to 255
# 2           smallint      2 bytes   -32,768 to 32,767                             0 to 65,535
# 3           mediumint     3 bytes   -8,388,608 to 8,388,607                       0 to 16,777,215
# nil, 4, 11  int(11)       4 bytes   -2,147,683,648 to 2,147,483,647	              0 to 4,294,967,295
# 5 to 8      bigint        8 bytes   -9223372036854775808 to 9223372036854775807   0 to 18,446,744,073,709,551,615
#             datetime      8 bytes
#             text          9-12 bytes (actual data stored outside of row)
# ... this is all too db specific, after all, disk storage is cheaper than trying to maintain all
#     of the integer types from the original snort schema for different db's, i.e. int will cover 
#     them all (tinyint, smallint, mediumint) and isn't that much more space
# ... avoid db specific definition like -> t.column :udp_csum, 'SMALLINT UNSIGNED' for mysql, which 
#     may be different for other db's
# *** also, we are only copying the data from snort events into this table and it will not be updated by users!
#
# 47 integer columns * 4 bytes each = 188
# 4 datetime columns * 8 bytes each = 32
# 6 text columns * 12 bytes each = 72 (note that the actual data is stored outside of the row)
# total bytes = 188 + 32 + 72 = 292
# 65,535 bytes is max row size - 292 this tables max bytes = 65,243
#
# ... Why were the snort tables normalized for such a tiny amount of data ?
#     Denormalizing would have avoided all of the expensive table joins necessary just to display an event !
#     Why not include the humanized versions of ip_src and ip_dst columns instead of calculating them everytime ?
#
  def change
    create_table :incident_events do |t|
      t.integer   :incident_id
      t.timestamps

      # event:
      t.datetime  :timestamp
      t.integer   :sid
      t.integer   :cid
      t.integer   :signature

      # schema:
      t.integer   :vseq
      t.datetime  :ctime

      # sensor:
      # t.integer   :sid
      t.text      :hostname
      t.text      :interface
      t.text      :filter
      t.integer   :detail
      t.integer   :encoding
      t.integer   :last_cid

      # detail (sensor_detail):
      t.integer   :detail_type
      t.text      :detail_text

      # encoding (sensor_encoding):
      t.integer   :encoding_type
      t.text      :encoding_text

      # signature (signature_detail):
      t.integer   :sig_id
      t.text      :sig_name
      t.integer   :sig_class_id
      t.integer   :sig_priority
      t.integer   :sig_rev
      t.integer   :sig_sid
      t.integer   :sig_gid

      # sig_class (signature_class):
      # t.integer   :sig_class_id
      t.string    :sig_class_name

      # signature_reference (sig_reference):
      # t.integer   :sig_id
      # t.integer   :ref_seq
      # t.integer   :ref_id

      # reference:
      # t.integer   :ref_id
      # t.integer   :ref_system_id
      # t.text      :ref_tag

      # reference_system:
      # t.integer   :ref_system_id
      # t.string    :ref_system_name

      # note: we don't need all of those "id's" from the original tables
      #       (signature_reference, reference, reference_system), but 
      #       just the values for ref_tag and ref_system_name
      # also: these values aren't searched or used very often so we store 
      #       them as a serialized hash in this attribute/field/column:
      t.text      :ref_tags_and_system_names

      # iphdr:
      # FIXME allow null in all fields!!!
      t.column    :ip_src, 'INT UNSIGNED NOT NULL'
      t.string    :ip_source
      t.column    :ip_dst, 'INT UNSIGNED NOT NULL'
      t.string    :ip_destination
      t.integer   :ip_ver
      t.integer   :ip_hlen
      t.integer   :ip_tos
      t.integer   :ip_len
      t.integer   :ip_id
      t.integer   :ip_flags
      t.integer   :ip_off
      t.integer   :ip_ttl
      t.integer   :ip_proto
      t.integer   :ip_csum

      # icmphdr:
      t.integer   :icmp_type
      t.integer   :icmp_code
      t.integer   :icmp_csum
      t.integer   :icmp_id
      t.integer   :icmp_seq

      # tcphdr:
      t.integer   :tcp_sport
      t.integer   :tcp_dport
      t.integer   :tcp_seq
      t.integer   :tcp_ack
      t.integer   :tcp_off
      t.integer   :tcp_res
      t.integer   :tcp_flags
      t.integer   :tcp_win
      t.integer   :tcp_csum
      t.integer   :tcp_urp

      #udphdr:
      t.integer   :udp_sport
      t.integer   :udp_dport
      t.integer   :udp_len
      t.integer   :udp_csum

      # data (payload):
      t.text      :data_payload
    end
  end
end
