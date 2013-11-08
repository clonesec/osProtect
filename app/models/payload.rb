class Payload < ActiveRecord::Base
  self.table_name = 'data'
  self.pluralize_table_names = false

  # see 'composite_primary_keys' gem for info:
  # set_primary_keys :sid, :cid
  self.primary_keys = [:sid, :cid]

  belongs_to :sensor, foreign_key: :sid
  belongs_to :event, foreign_key: [:sid, :cid]

  def to_ascii
    # thanks to the hexy gem for the following code:
    str = ""
    @bytes      = [self.data_payload].pack('H*')
    @width      = 16 
    @numbering  = :hex_bytes
    @format     = :twos
    @case       = :lower
    @annotate   = :ascii
    @prefix     = ""
    @indent     = 0
    1.upto(@indent) {@prefix += " "}
    0.step(@bytes.length, @width) do |i|
      string = @bytes[i,@width]
      hex = string.unpack("H*")[0]
      hex.upcase! if @case == :upper
      if @format == :fours
        hex.gsub!(/(.{4})/) { |m| m + " " }
      elsif @format == :twos
        hex.sub!(/(.{#{@width}})/) { |m| m + "  " }
        hex.gsub!(/(\S\S)/) { |m| m + " " }
      end
      # Sep 23, 2013: this fails:
      # string.gsub!(/[\000-\040\177-\377]/, ".")
      # fixes the above:
      string.gsub!(Regexp.new("[\000-\040\177-\377]", nil, 'n'), ".")
      string.gsub!(/(.{#{@width/2}})/) { |m| m + " " }
      len = case @format
              when :fours 
                (@width*2)+(@width/2) 
              when :twos
                (@width * 3)+2
              else
                @width *2
            end  
      str << @prefix
      str << "%07X: " % (i) if @numbering == :hex_bytes 
      str << ("%-#{len}s" % hex)
      str << " #{string}" if @annotate == :ascii
      str << "\n" 
    end
    str << "\n"
  end

end
