# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131104164630) do

  create_table "borrowed_rule_files", force: true do |t|
    t.integer  "user_id"
    t.integer  "rules_location_id"
    t.string   "file_name"
    t.string   "file_path"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "borrowed_rule_files", ["file_name"], name: "index_borrowed_rule_files_on_file_name", using: :btree
  add_index "borrowed_rule_files", ["rules_location_id"], name: "index_borrowed_rule_files_on_rules_location_id", using: :btree
  add_index "borrowed_rule_files", ["user_id"], name: "index_borrowed_rule_files_on_user_id", using: :btree

  create_table "data", id: false, force: true do |t|
    t.integer "sid",          null: false
    t.integer "cid",          null: false
    t.text    "data_payload"
  end

  create_table "detail", primary_key: "detail_type", force: true do |t|
    t.text "detail_text", null: false
  end

  create_table "encoding", primary_key: "encoding_type", force: true do |t|
    t.text "encoding_text", null: false
  end

  create_table "event", id: false, force: true do |t|
    t.integer  "sid",       null: false
    t.integer  "cid",       null: false
    t.integer  "signature", null: false
    t.datetime "timestamp", null: false
  end

  add_index "event", ["signature"], name: "sig", using: :btree
  add_index "event", ["timestamp"], name: "time", using: :btree

  create_table "group_sensors", force: true do |t|
    t.integer  "group_id"
    t.integer  "sensor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_sensors", ["group_id"], name: "index_group_sensors_on_group_id", using: :btree
  add_index "group_sensors", ["sensor_id"], name: "index_group_sensors_on_sensor_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "icmphdr", id: false, force: true do |t|
    t.integer "sid",                 null: false
    t.integer "cid",                 null: false
    t.integer "icmp_type", limit: 1, null: false
    t.integer "icmp_code", limit: 1, null: false
    t.integer "icmp_csum", limit: 2
    t.integer "icmp_id",   limit: 2
    t.integer "icmp_seq",  limit: 2
  end

  add_index "icmphdr", ["icmp_type"], name: "icmp_type", using: :btree

  create_table "incident_events", force: true do |t|
    t.integer  "incident_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "timestamp"
    t.integer  "sid"
    t.integer  "cid"
    t.integer  "signature"
    t.integer  "vseq"
    t.datetime "ctime"
    t.text     "hostname"
    t.text     "interface"
    t.text     "filter"
    t.integer  "detail"
    t.integer  "encoding"
    t.integer  "last_cid"
    t.integer  "detail_type"
    t.text     "detail_text"
    t.integer  "encoding_type"
    t.text     "encoding_text"
    t.integer  "sig_id"
    t.text     "sig_name"
    t.integer  "sig_class_id"
    t.integer  "sig_priority"
    t.integer  "sig_rev"
    t.integer  "sig_sid"
    t.integer  "sig_gid"
    t.string   "sig_class_name"
    t.text     "ref_tags_and_system_names"
    t.integer  "ip_src",                    null: false
    t.string   "ip_source"
    t.integer  "ip_dst",                    null: false
    t.string   "ip_destination"
    t.integer  "ip_ver"
    t.integer  "ip_hlen"
    t.integer  "ip_tos"
    t.integer  "ip_len"
    t.integer  "ip_id"
    t.integer  "ip_flags"
    t.integer  "ip_off"
    t.integer  "ip_ttl"
    t.integer  "ip_proto"
    t.integer  "ip_csum"
    t.integer  "icmp_type"
    t.integer  "icmp_code"
    t.integer  "icmp_csum"
    t.integer  "icmp_id"
    t.integer  "icmp_seq"
    t.integer  "tcp_sport"
    t.integer  "tcp_dport"
    t.integer  "tcp_seq"
    t.integer  "tcp_ack"
    t.integer  "tcp_off"
    t.integer  "tcp_res"
    t.integer  "tcp_flags"
    t.integer  "tcp_win"
    t.integer  "tcp_csum"
    t.integer  "tcp_urp"
    t.integer  "udp_sport"
    t.integer  "udp_dport"
    t.integer  "udp_len"
    t.integer  "udp_csum"
    t.text     "data_payload"
  end

  create_table "incidents", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.string   "incident_name"
    t.string   "status",               default: "pending"
    t.text     "incident_description"
    t.text     "incident_resolution"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notification_id"
  end

  create_table "iphdr", id: false, force: true do |t|
    t.integer "sid",                null: false
    t.integer "cid",                null: false
    t.integer "ip_src",             null: false
    t.integer "ip_dst",             null: false
    t.integer "ip_ver",   limit: 1
    t.integer "ip_hlen",  limit: 1
    t.integer "ip_tos",   limit: 1
    t.integer "ip_len",   limit: 2
    t.integer "ip_id",    limit: 2
    t.integer "ip_flags", limit: 1
    t.integer "ip_off",   limit: 2
    t.integer "ip_ttl",   limit: 1
    t.integer "ip_proto", limit: 1, null: false
    t.integer "ip_csum",  limit: 2
  end

  add_index "iphdr", ["ip_dst"], name: "ip_dst", using: :btree
  add_index "iphdr", ["ip_src"], name: "ip_src", using: :btree

  create_table "logs", force: true do |t|
    t.text     "debug_msg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "role",       default: "user"
    t.integer  "roles_mask"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree

  create_table "notification_signature_sections", force: true do |t|
    t.integer  "notification_id"
    t.string   "title"
    t.text     "description"
    t.text     "signature_ids"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "notification_signature_sections", ["notification_id"], name: "index_notification_signature_sections_on_notification_id", using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.boolean  "run_status",                default: false
    t.text     "notify_criteria"
    t.text     "notify_criteria_as_string"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "name"
    t.text     "description"
    t.boolean  "events_in_email",           default: false
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "opt", id: false, force: true do |t|
    t.integer "sid",                 null: false
    t.integer "cid",                 null: false
    t.integer "optid",               null: false
    t.integer "opt_proto", limit: 1, null: false
    t.integer "opt_code",  limit: 1, null: false
    t.integer "opt_len",   limit: 2
    t.text    "opt_data"
  end

  create_table "pdfs", force: true do |t|
    t.integer  "user_id"
    t.integer  "pdf_type"
    t.integer  "report_id"
    t.string   "path_to_file"
    t.string   "file_name"
    t.text     "creation_criteria"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "notification_id"
  end

  create_table "reference", primary_key: "ref_id", force: true do |t|
    t.integer "ref_system_id", null: false
    t.text    "ref_tag",       null: false
  end

  create_table "reference_system", primary_key: "ref_system_id", force: true do |t|
    t.string "ref_system_name", limit: 20
  end

  create_table "report_groups", force: true do |t|
    t.integer  "report_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "report_groups", ["group_id"], name: "index_report_groups_on_group_id", using: :btree
  add_index "report_groups", ["report_id"], name: "index_report_groups_on_report_id", using: :btree

  create_table "report_signature_sections", force: true do |t|
    t.integer  "report_id"
    t.string   "title"
    t.text     "description"
    t.text     "signature_ids"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "report_signature_sections", ["report_id"], name: "index_report_signature_sections_on_report_id", using: :btree

  create_table "reports", force: true do |t|
    t.integer  "user_id"
    t.boolean  "for_all_users",                       default: false
    t.integer  "report_type",                         default: 1
    t.boolean  "run_status",                          default: false
    t.string   "auto_run_at",               limit: 1, default: "n"
    t.boolean  "include_summary",                     default: false
    t.string   "name"
    t.text     "report_criteria"
    t.string   "report_criteria_as_string"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "include_events",                      default: false
    t.text     "introduction"
  end

  create_table "rules", force: true do |t|
    t.integer  "rules_location_id"
    t.integer  "linenum"
    t.text     "rawtext"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "rules", ["rules_location_id"], name: "index_rules_on_rules_location_id", using: :btree

  create_table "rules_locations", force: true do |t|
    t.string   "name"
    t.string   "rules_folder"
    t.string   "url_domain_ip",            default: "127.0.0.1"
    t.integer  "url_port",                 default: 8500
    t.string   "url_protocol",             default: "http"
    t.string   "info_path",                default: "info"
    t.string   "list_folder_path",         default: "list_folder"
    t.string   "list_rules_in_file_path",  default: "list_rules_in_file"
    t.string   "write_rules_to_file_path", default: "write_rules_to_file"
    t.integer  "request_timeout",          default: 30000
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "schema", primary_key: "vseq", force: true do |t|
    t.datetime "ctime", null: false
  end

  create_table "sensor", primary_key: "sid", force: true do |t|
    t.text    "hostname"
    t.text    "interface"
    t.text    "filter"
    t.integer "detail",    limit: 1
    t.integer "encoding",  limit: 1
    t.integer "last_cid",            null: false
  end

  create_table "sensor_names", force: true do |t|
    t.integer  "sensor_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sensor_names", ["sensor_id"], name: "index_sensor_names_on_sensor_id", using: :btree

  create_table "sig_class", primary_key: "sig_class_id", force: true do |t|
    t.string "sig_class_name", limit: 60, null: false
  end

  add_index "sig_class", ["sig_class_id"], name: "sig_class_id", using: :btree
  add_index "sig_class", ["sig_class_name"], name: "sig_class_name", using: :btree

  create_table "sig_reference", id: false, force: true do |t|
    t.integer "sig_id",  null: false
    t.integer "ref_seq", null: false
    t.integer "ref_id",  null: false
  end

  create_table "signature", primary_key: "sig_id", force: true do |t|
    t.string  "sig_name",     null: false
    t.integer "sig_class_id", null: false
    t.integer "sig_priority"
    t.integer "sig_rev"
    t.integer "sig_sid"
    t.integer "sig_gid"
  end

  add_index "signature", ["sig_class_id"], name: "sig_class_id_idx", using: :btree
  add_index "signature", ["sig_name"], name: "sign_idx", length: {"sig_name"=>20}, using: :btree

  create_table "tcphdr", id: false, force: true do |t|
    t.integer "sid",                 null: false
    t.integer "cid",                 null: false
    t.integer "tcp_sport", limit: 2, null: false
    t.integer "tcp_dport", limit: 2, null: false
    t.integer "tcp_seq"
    t.integer "tcp_ack"
    t.integer "tcp_off",   limit: 1
    t.integer "tcp_res",   limit: 1
    t.integer "tcp_flags", limit: 1, null: false
    t.integer "tcp_win",   limit: 2
    t.integer "tcp_csum",  limit: 2
    t.integer "tcp_urp",   limit: 2
  end

  add_index "tcphdr", ["tcp_dport"], name: "tcp_dport", using: :btree
  add_index "tcphdr", ["tcp_flags"], name: "tcp_flags", using: :btree
  add_index "tcphdr", ["tcp_sport"], name: "tcp_sport", using: :btree

  create_table "udphdr", id: false, force: true do |t|
    t.integer "sid",                 null: false
    t.integer "cid",                 null: false
    t.integer "udp_sport", limit: 2, null: false
    t.integer "udp_dport", limit: 2, null: false
    t.integer "udp_len",   limit: 2
    t.integer "udp_csum",  limit: 2
  end

  add_index "udphdr", ["udp_dport"], name: "udp_dport", using: :btree
  add_index "udphdr", ["udp_sport"], name: "udp_sport", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "no_events_yesterday_notification", default: false
  end

end
