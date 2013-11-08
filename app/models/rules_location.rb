class RulesLocation < ActiveRecord::Base
  has_many :borrowed_rule_files
  # attr_accessible :name, :rules_folder, :url_domain_ip, :url_port, :url_protocol, :rules_files_location
  attr_accessor :rules_files_location

  validates :name, presence: true
  validates :rules_folder, presence: true

  before_save :set_local_or_remote

  private

  def set_local_or_remote
    self.rules_files_location = 'local' if self.url_domain_ip.blank?
    if self.rules_files_location == 'local'
      self.url_domain_ip = nil
      self.url_port = nil
      self.url_protocol = nil
    else
      self.url_protocol = 'http'
    end
  end
end
