class BorrowedRuleFile < ActiveRecord::Base
  belongs_to :user
  belongs_to :rules_location
  has_many :rules
  # attr_accessible :file_name, :file_path

  def self.is_borrowed_by(file)
    borrowed = BorrowedRuleFile.find_by_file_name(file)
    if borrowed
      borrowed.user.username
    else
      ''
    end
  end
end
