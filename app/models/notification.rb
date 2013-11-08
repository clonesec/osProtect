class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :pdfs, dependent: :destroy
  has_many :notification_signature_sections, inverse_of: :notification, dependent: :destroy
  accepts_nested_attributes_for :notification_signature_sections, allow_destroy: true

  serialize :notify_criteria, ActiveSupport::HashWithIndifferentAccess

  before_validation :set_notify_criteria_as_string

  validates :name, presence: true
  validates :description, presence: true
  validates :notify_criteria_as_string,
            uniqueness: {scope: :user_id, message: "you already have a Notification with the same criteria!"}
  validate :minimum_matches_ok
  validate :source_address_ok
  validate :source_port_ok
  validate :destination_address_ok
  validate :destination_port_ok

  def disabled
    self.run_status == false
  end

  def status
    self.run_status ? 'enabled' : 'disabled'
  end

  def notify_email(user)
    self.email.blank? ? user.email : self.email
  end

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def self.minimum_matches_selections
    mm = []
    mm << Selection.new({id:  '0', name: 'Any'})
    mm << Selection.new({id:  '1', name: '1 or more matching events'})
    mm << Selection.new({id:  '3', name: '3 or more matching events'})
    mm << Selection.new({id:  '5', name: '5 or more matching events'})
    mm << Selection.new({id:  '7', name: '7 or more matching events'})
    mm << Selection.new({id: '10', name: '10 or more matching events'})
    mm
  end

  private

  def set_notify_criteria_as_string
    self.notify_criteria_as_string =  "user_id=#{self.user.id}," + self.notify_criteria.to_s
  end

  def minimum_matches_ok
    self.errors[:minimum_matches] << "must be a number" unless Iphdr.numeric?(self.notify_criteria[:minimum_matches])
  end

  def source_address_ok
    self.errors[:source_address] << "is invalid" unless Iphdr.is_valid?(self.notify_criteria[:source_address])
  end

  def source_port_ok
    self.errors[:source_port] << "must be a number" unless Iphdr.numeric?(self.notify_criteria[:source_port])
  end

  def destination_address_ok
    self.errors[:destination_address] << "is invalid" unless Iphdr.is_valid?(self.notify_criteria[:destination_address])
  end

  def destination_port_ok
    self.errors[:destination_port] << "must be a number" unless Iphdr.numeric?(self.notify_criteria[:destination_port])
  end
end
