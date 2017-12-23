module M3U8
  # TimeItem represents EXT-X-PROGRAM-DATE-TIME
  class TimeItem
    property time : Time

    def initialize(params)
      @time = parse_time(params)
    end
    
    # def self.parse(text)
    #   time = text.gsub("#EXT-X-PROGRAM-DATE-TIME:", "")
    #   new({ time: Time.iso8601(time) })
    # end

    def to_s
      %(#EXT-X-PROGRAM-DATE-TIME:#{time_format})
    end

    private def parse_time(time)
      case time
      when String
        Time.iso8601(time)
      when Time
        time
      end.not_nil!
    end

    private def time_format
      time.iso8601
    end
  end
end
