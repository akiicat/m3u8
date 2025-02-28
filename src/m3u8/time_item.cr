module M3U8
  # `TimeItem` represents an `EXT-X-PROGRAM-DATE-TIME` tag in an HLS playlist.
  #
  # The `EXT-X-PROGRAM-DATE-TIME` tag (as defined in [RFC 8216, Section 4.3.2.6](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.6)) is used to
  # associate the first sample of a Media Segment with an absolute date and time. The time
  # is formatted in [ISO 8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf), ensuring a consistent representation across clients.
  #
  # For example:
  #
  # ```
  # # EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z
  # ```
  #
  # This class encapsulates a `Time` value and provides methods for parsing, formatting, and
  # checking whether a `TimeItem` is "empty" (i.e. represents the Unix epoch).
  #
  # Examples:
  #
  # Parsing various inputs:
  # ```
  # # Passing a TimeItem returns the same instance
  # TimeItem.parse(TimeItem.new("2010-02-19T14:54:23Z"))
  #
  # # Parsing a Time value directly
  # TimeItem.parse(Time.parse_iso8601("2010-02-19T14:54:23.031Z"))
  #
  # # Parsing a time string in ISO8601 format
  # TimeItem.parse("2010-02-19T14:54:23.031Z")
  #
  # # Calling parse with no argument returns a default TimeItem (Unix epoch)
  # TimeItem.parse
  # ```
  #
  # Creating a new `TimeItem`:
  # ```
  # TimeItem.new("2010-02-19T14:54:23Z")
  # # => #<M3U8::TimeItem:0x10581b920 @time=2010-02-19 14:54:23 UTC>
  #
  # TimeItem.new(Time.parse_iso8601("2010-02-19T14:54:23.031Z"))
  # # => #<M3U8::TimeItem:0x10581b920 @time=2010-02-19 14:54:23 UTC>
  #
  # TimeItem.new
  # # => #<M3U8::TimeItem:0x10581b880 @time=1970-01-01 00:00:00 UTC>
  # ```
  #
  # Checking if a `TimeItem` is empty (i.e. represents the Unix epoch):
  # ```
  # item = TimeItem.new
  # item.empty? # => true
  #
  # item = TimeItem.new("2010-02-19T14:54:23Z")
  # item.empty? # => false
  # ```
  #
  # Converting a `TimeItem` to a string:
  # ```
  # TimeItem.new("2010-02-19T14:54:23Z").to_s
  # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
  #
  # TimeItem.new(Time.parse_iso8601("2010-02-19T14:54:23.031Z")).to_s
  # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
  # ```
  class TimeItem
    include Concern

    # The `EXT-X-PROGRAM-DATE-TIME` tag associates the first sample of a
    # Media Segment with an absolute date and/or time.
    property time : Time

    # Parses an input item into a `TimeItem`.
    #
    # If the input is already a `TimeItem`, it is returned as-is.
    # Otherwise, it attempts to create a new `TimeItem` from the input.
    #
    # Examples:
    # ```
    # TimeItem.parse(TimeItem.new("2010-02-19T14:54:23Z"))
    # # => #<M3U8::TimeItem:0x783c78510c60 @time=2010-02-19 14:54:23.0 UTC>
    #
    # TimeItem.parse(Time.parse_iso8601("2010-02-19T14:54:23.031Z"))
    # # => #<M3U8::TimeItem:0x783c78517f00 @time=2010-02-19 14:54:23.031000000 UTC>
    #
    # TimeItem.parse("2010-02-19T14:54:23.031Z")
    # # => #<M3U8::TimeItem:0x783c78517de0 @time=2010-02-19 14:54:23.031000000 UTC>
    #
    # TimeItem.parse
    # # => #<M3U8::TimeItem:0x783c78517cc0 @time=1970-01-01 00:00:00.0 UTC>
    # ```
    def self.parse(item = nil)
      case item
      when TimeItem then item
      else               new(item)
      end
    end

    # Constructs a new `TimeItem` using a NamedTuple with a `:time` key.
    #
    # Examples:
    # ```
    # TimeItem.new({time: Time.parse_iso8601("2010-02-19T14:54:23.031Z")})
    # # => #<M3U8::TimeItem:0x7e461bbd8ba0 @time=2010-02-19 14:54:23.031000000 UTC>
    #
    # TimeItem.new({time: Time.parse_iso8601("2010-02-19T14:54:23.031Z")})
    # # => #<M3U8::TimeItem:0x7bb643931a80 @time=1970-01-01 00:00:00.0 UTC>
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(time: params[:time]?)
    end

    # Initializes a new `TimeItem`.
    #
    # If no time is provided, it defaults to the Unix epoch (1970-01-01 00:00:00 UTC).
    #
    # Examples:
    # ```
    # TimeItem.new("2010-02-19T14:54:23Z")
    # # => #<M3U8::TimeItem:0x79134e1fd960 @time=2010-02-19 14:54:23.0 UTC>
    #
    # TimeItem.new(Time.parse_iso8601("2010-02-19T14:54:23.031Z"))
    # # => #<M3U8::TimeItem:0x79134e1fd840 @time=2010-02-19 14:54:23.031000000 UTC>
    #
    # TimeItem.new
    # # => #<M3U8::TimeItem:0x79134e1fd720 @time=1970-01-01 00:00:00.0 UTC>
    # ```
    def initialize(time = nil)
      @time = parse_time(time)
    end

    # Returns true if the `TimeItem`'s time represents the Unix epoch.
    #
    # This can be used to check whether the `TimeItem` has been set to a meaningful time.
    #
    # Examples:
    # ```
    # item = TimeItem.new
    # item.empty? # => true
    #
    # item = TimeItem.new("2010-02-19T14:54:23Z")
    # item.empty? # => false
    # ```
    def empty?
      @time.to_unix.zero?
    end

    # Returns the string representation of the `EXT-X-PROGRAM-DATE-TIME` tag.
    #
    # The output is generated by prefixing the
    # [ISO 8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf)-formatted time
    # with `#EXT-X-PROGRAM-DATE-TIME:`.
    #
    # Examples:
    # ```
    # TimeItem.new("2010-02-19T14:54:23Z").to_s
    # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z"
    #
    # TimeItem.new(Time.parse_iso8601("2010-02-19T14:54:23.031Z")).to_s
    # # => "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
    # ```
    def to_s
      return "" if empty?
      %(#EXT-X-PROGRAM-DATE-TIME:#{time_format})
    end

    private def time_format
      time.to_s("%FT%T.%L%:z")
    end

    private def parse_time(time)
      case time
      when String then Time.parse_iso8601(time)
      when Time   then time
      else             Time.unix 0
      end
    end
  end
end
