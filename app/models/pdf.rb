class Pdf < ActiveRecord::Base
  belongs_to :user
  belongs_to :report

  serialize :creation_criteria, ActiveSupport::HashWithIndifferentAccess
end
