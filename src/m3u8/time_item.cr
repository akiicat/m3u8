module M3U8
  # TimeItem represents EXT-X-PROGRAM-DATE-TIME
  class TimeItem
    include Concern

    property time : Time

    # ```
    # TimeItem.parse(TimeItem.new("2010-02-19T14:54:23Z"))
    # TimeItem.parse(Time.iso8601("2010-02-19T14:54:23.031Z"))
    # TimeItem.parse("2010-02-19T14:54:23.031Z")
    # TimeItem.parse
    # ```
    def self.parse(item = nil)
      case item
      when TimeItem then item
      else new(item)
      end
    end

    # ```
    # Time.iso8601("2010-02-19T14:54:23.031Z")
    # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(time: params[:time]?)
    end

    # ```
    # TimeItem.new("2010-02-19T14:54:23Z")
    # # => #<M3U8::TimeItem:0x10581b920 @time=2010-02-19 14:54:23 UTC>
    # TimeItem.new(Time.iso8601("2010-02-19T14:54:23.031Z"))
    # # => #<M3U8::TimeItem:0x10581b920 @time=2010-02-19 14:54:23 UTC>
    # TimeItem.new
    # # => #<M3U8::TimeItem:0x10581b880 @time=1970-01-01 00:00:00 UTC>
    # ```
    def initialize(time = nil)
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

    private def parse_time(time)
      case time
      when String then Time.iso8601(time)
      when Time then time
      else Time.epoch 0
      end
    end
  end
end

