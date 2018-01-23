module M3U8
  # TimeItem represents EXT-X-PROGRAM-DATE-TIME
  class TimeItem
    include Concern

    property time : Time

    def self.new(params : NamedTuple = NamedTuple.new)
      new(time: params[:time]?)
    end

    def initialize(time)
      @time = parse_time(time)
    end

    def empty?
      @time.epoch.zero?
    end

    def to_s
      return "" if empty?
      %(#EXT-X-PROGRAM-DATE-TIME:#{time_format})
    end

    private def time_format
      time.iso8601
    end
  end
end
