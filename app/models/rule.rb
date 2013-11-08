class Rule < ActiveRecord::Base
  belongs_to :rules_location
  # attr_accessible :linenum, :rawtext

  validates :rawtext, presence: {message: "can't be blank"}

  def self.next_linenum
    last_rule = Rule.last
    return 1 if last_rule.blank?
    n = last_rule.linenum
    return 1 if n.blank?
    n + 1
  end

  def mass_insert_initialize(rules_location_id)
    @rules_location_id = rules_location_id
    # make all text lines have the same UTC date/time for created_at & updated_at:
    @now = DateTime.now.utc.to_formatted_s(:db)
    @values = []
    @line_count = 0
  end

  def append_line_to_mass_insert_values
    @line_count += 1
    @values << " (#{@rules_location_id}, #{@line_count}, '#{quote_string(self.rawtext)}', '#{@now}', '#{@now}')"
  end

  def mass_insert_into_rules_table
    return if @values.blank?
    Rule.connection.execute "insert into rules " +
      "(rules_location_id, linenum, rawtext, created_at, updated_at) " +
      "values " + @values.join(',')
  end

  private

  def quote_string(v)
    v.to_s.gsub(/\\/, '\&\&').gsub(/'/, "''")
  end
end
