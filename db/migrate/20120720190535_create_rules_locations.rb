class CreateRulesLocations < ActiveRecord::Migration
  def change
    create_table :rules_locations do |t|
      t.string      :name
      t.string      :rules_folder
      t.string      :url_domain_ip,             default: '127.0.0.1'
      t.integer     :url_port,                  default: 8500
      t.string      :url_protocol,              default: 'http'
      t.string      :info_path,                 default: 'info'
      t.string      :list_folder_path,          default: 'list_folder'
      t.string      :list_rules_in_file_path,   default: 'list_rules_in_file'
      t.string      :write_rules_to_file_path,  default: 'write_rules_to_file'
      t.integer     :request_timeout,           default: 30000
      t.timestamps
    end
  end
end
