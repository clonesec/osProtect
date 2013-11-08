class Incident < ActiveRecord::Base
  belongs_to :group
  has_many :incident_events, dependent: :destroy

  attr_accessor :events_added_count, :events_rejected_count

  validates_presence_of :incident_name

  def events_added_count
    @events_added_count.blank? ? 0 : @events_added_count
  end

  def events_rejected_count
    @events_rejected_count.blank? ? 0 : @events_rejected_count
  end

  def status_class
    return 'ok'   if self.status.downcase == 'resolved'
    return 'warn' if self.status.downcase == 'suspicious'
    'error'
  end

  class Selection
    attr_accessor :id, :name
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end unless attributes.nil?
    end
  end

  def self.status_selections
    ss = []
    ss << Selection.new({id: 'pending', name: 'pending'})
    ss << Selection.new({id: 'suspicious', name: 'suspicious'})
    ss << Selection.new({id: 'resolved', name: 'resolved'})
    ss
  end
end
