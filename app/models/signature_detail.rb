class SignatureDetail < ActiveRecord::Base
  self.table_name = 'signature'
  self.pluralize_table_names = false
  self.primary_key = 'sig_id'
  alias_attribute :id, :sig_id

  has_many :events, foreign_key: 'signature'
  has_many :signature_references, :foreign_key => 'sig_id'
  belongs_to :signature_class, class_name: "SignatureClass", foreign_key: 'sig_class_id', primary_key: 'sig_class_id'

  def self.get_selections(user)
    signatures = self.select('sig_id, sig_name').order("sig_name asc")
    sigs = []
    signatures.each do |s|
      sigs = sigs << [s.sig_name, s.sig_id]
    end
    sigs
  end

  def self.selections(user)
    # FIXME the following should only show Signatures available for the current user, but it doesn't ?
    # # note: if user is an admin, groups/memberships don't matter since an admin can do anything:
    # if user.role? :admin
    #   signatures = self.select('sig_id, sig_name').order("sig_name asc")
    # else
    #   # get user's sensors based on group memberships:
    #   sensors_for_user = user.sensors
    #   if sensors_for_user.blank?
    #     sensors = []
    #     flash.now[:error] = "No sensors were found for you, perhaps you are not a member of any group. Please contact an administrator to resolve this issue."
    #     return
    #   else
    #     # limit Signatures based on this user's groups/memberships:
    #     signatures = Event.where("event.sid IN (?)", sensors_for_user).includes(:sensor, :signature_detail).select('signature.sig_id, signature.sig_name').order("signature.sig_name asc")
    #   end
    # end
    # signatures
    signatures = self.select('sig_id, sig_name').order(sig_name: :asc)
  end

  def self.priorities(user)
    # priorities = self.select('distinct sig_priority, sig_priority').where("sig_priority IS NOT NULL").order("sig_priority asc")
    # ... or using Arel to avoid hard-coding db specific SQL:
    priorities = self.select('distinct sig_priority, sig_priority').where(self.arel_table[:sig_priority].not_eq(nil)).order(sig_priority: :asc)
  end
end
