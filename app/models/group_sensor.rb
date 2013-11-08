class GroupSensor < ActiveRecord::Base
  belongs_to :group
  belongs_to :sensor
end
