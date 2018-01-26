module M3U8
  # TimeItem represents EXT-X-PROGRAM-DATE-TIME
  class TimeItem
    include Concern

    property time : Time

    # ```
    # Time.iso8601("2010-02-19T14:54:23.031Z"),
    # "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(time: params[:time]?)
    end

    # ```
    # TimeItem.new("2010-02-19T14:54:23Z")
    # TimeItem.new(Time.iso8601("2010-02-19T14:54:23.031Z"))
    # ```
    def initialize(time)
      @time = parse_time(time)
    end

    # ```
    # item = TimeItem.new
    # item.empty? # => true
    # item = TimeItem.new("2010-02-19T14:54:23Z")
    # item.empty? # => false
    # ```
    def empty?
      @time.epoch.zero?
    end

    # ```
    # TimeItem.new("2010-02-19T14:54:23Z").to_s
    # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
    # TimeItem.new(Time.iso8601("2010-02-19T14:54:23.031Z"))
    # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
    # ```
    def to_s
      return "" if empty?
      %(#EXT-X-PROGRAM-DATE-TIME:#{time_format})
    end

    private def time_format
      time.iso8601
    end
  end
end

