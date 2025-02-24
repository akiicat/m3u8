module M3U8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.

  # `SegmentItem` represents a media segment in an HLS playlist.
  #
  # It encapsulates the information provided by the `EXTINF` tag followed by the media segment URI.
  #
  # According to [RFC 8216, Section 4.3.2.1](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.1),
  # The `EXTINF` tag specifies the `duration` of a Media Segment and may include an
  # optional title or `comment`.  It applies only to the next Media Segment.
  #
  # Its format is:
  #
  # ```txt
  # #EXTINF:<duration>,[<title>]
  # ```
  #
  # For example:
  #
  # ```txt
  # #EXTINF:10.991,anything
  # ```
  #
  # This indicates that the following media segment has a `duration` of 10.991 seconds
  # with an optional `comment` "anything".
  #
  # In addition, a `SegmentItem` may optionally include:
  #   - An `EXT-X-BYTERANGE` tag (`ByteRange`) that specifies a sub-range of the media resource. ([RFC 8216, Section 4.3.2.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.2))
  #   - An `EXT-X-PROGRAM-DATE-TIME` tag (`Time` or `TimeItem`) that associates an absolute date and time
  #     with the first sample of the following Media Segment. ([RFC 8216, Section 4.3.2.6](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.6))
  #
  # Properties:
  # - **`duration`**: The duration of the segment as specified by the `EXTINF` tag.
  # - **`segment`**:  The *URI* of the media segment.
  # - **`comment`**:  An optional comment from the `EXTINF` tag.
  # - **`byterange`**: A `ByteRange` object representing the sub-range of the segment, if specified.
  # - **`program_date_time`**: A `TimeItem` object representing the absolute time associated with the segment.
  #
  # Examples:
  #
  # Creating a `SegmentItem` instance:
  #
  # ```crystal
  # options = {
  #   duration:  10.991,
  #   segment:   "test.ts",
  #   comment:   "anything",
  #   byterange: {length: 4500, start: 600},
  # }
  # SegmentItem.new(options)
  # # => #<M3U8::SegmentItem:0x7e310e075cc0
  # #     @byterange=#<M3U8::ByteRange:0x7e310f201c00 @length=4500, @start=600>,
  # #     @comment="anything",
  # #     @duration=10.991,
  # #     @program_date_time=#<M3U8::TimeItem:0x7e310e0761b0 @time=1970-01-01 00:00:00.0 UTC>,
  # #     @segment="test.ts">
  #
  # SegmentItem.new(10.991, "test.ts", "anything", "4500@600", "2010-02-19T14:54:23.031Z")
  # # => #<M3U8::SegmentItem:0x7e6830943b40
  # #     @byterange=#<M3U8::ByteRange:0x7e6831acf990 @length=4500, @start=600>,
  # #     @comment="anything",
  # #     @duration=10.991,
  # #     @program_date_time=#<M3U8::TimeItem:0x7e6830949cf0 @time=2010-02-19 14:54:23.031000000 UTC>,
  # #     @segment="test.ts">
  # ```
  #
  # Convert to a string representation of the `SegmentItem`:
  #
  # ```crystal
  # SegmentItem.new(10.991, "test.ts", "anything", "4500@600", "2010-02-19T14:54:23.031Z").to_s
  # # => "#EXTINF:10.991,anything\n" +
  # #    "#EXT-X-BYTERANGE:4500@600\n" +
  # #    "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z\n" +
  # #    "test.ts"
  # ```
  class SegmentItem
    include Concern

    # The required `duration` from the `EXTINF` tag.
    property duration : Float64?
    # The *URI* of the media segment.
    property segment : String?
    # An optional comment from the `EXTINF` tag.
    property comment : String?
    # The `ByteRange` specifying a sub-section of the segment (if provided).
    getter byterange : ByteRange
    # The program date/time (`TimeItem`) associated with the segment (if provided).
    getter program_date_time : TimeItem

    property duration : Float64?
    property segment : String?
    property comment : String?
    getter byterange : ByteRange
    getter program_date_time : TimeItem

    # Constructs a new `SegmentItem` from a NamedTuple.
    #
    # The NamedTuple may include the following keys:
    #   - `duration` (Float64): The duration of the segment.
    #   - `segment` (String): The *URI* of the media segment.
    #   - `comment` (String): A comment associated with the segment.
    #   - `byterange` (`ByteRange`, NamedTuple, or String): The `byterange`, which can be provided as a NamedTuple, `ByteRange`, or string.
    #   - `program_date_time` (`TimeItem`, `Time`, or String): The program date/time, which can be a `TimeItem`, Time, or [ISO8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf) string.
    #
    # Example:
    #
    # ```crystal
    # options = {
    #   duration:  10.991,
    #   segment:   "test.ts",
    #   comment:   "anything",
    #   byterange: {length: 4500, start: 600},
    #   program_date_time: "2010-02-19T14:54:23.031Z",
    # }
    # SegmentItem.new(options)
    # # => #<M3U8::SegmentItem:0x7e756d37b7c0
    # #     @byterange=#<M3U8::ByteRange:0x7e756e5074b0 @length=4500, @start=600>,
    # #     @comment="anything",
    # #     @duration=10.991,
    # #     @program_date_time=#<M3U8::TimeItem:0x7e756d386c60 @time=2010-02-19 14:54:23.031000000 UTC>,
    # #     @segment="test.ts">
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        duration: params[:duration]?,
        segment: params[:segment]?,
        comment: params[:comment]?,
        byterange: params[:byterange]?,
        program_date_time: params[:program_date_time]?,
      )
    end

    # Initializes a new `SegmentItem` instance.
    #
    # The parameters are assigned to the corresponding properties. The `byterange` (`Byterange`) and
    # `program_date_time` (`TimeItem`) parameters are parsed using their respective parsing methods,
    # allowing them to be provided in different forms (e.g. as a NamedTuple, string, or object).
    #
    # Examples:
    #
    # ```crystal
    # SegmentItem.new(10.991, "test.ts", "anything", "4500@600", "2010-02-19T14:54:23.031Z")
    # # => #<M3U8::SegmentItem:0x7e6830943b40
    # #     @byterange=#<M3U8::ByteRange:0x7e6831acf990 @length=4500, @start=600>,
    # #     @comment="anything",
    # #     @duration=10.991,
    # #     @program_date_time=#<M3U8::TimeItem:0x7e6830949cf0 @time=2010-02-19 14:54:23.031000000 UTC>,
    # #     @segment="test.ts">
    #
    # SegmentItem.new(
    #   duration: 10.991,
    #   segment: "test.ts",
    #   comment: "anything",
    #   byterange: {length: 4500, start: 600},
    #   program_date_time: Time.parse_iso8601("2010-02-19T14:54:23.031Z"),
    # )
    # # => #<M3U8::SegmentItem:0x7ffa96913700
    # #     @byterange=#<M3U8::ByteRange:0x7ffa97a9f3f0 @length=4500, @start=600>,
    # #     @comment="anything",
    # #     @duration=10.991,
    # #     @program_date_time=#<M3U8::TimeItem:0x7ffa9691e7b0 @time=2010-02-19 14:54:23.031000000 UTC>,
    # #     @segment="test.ts">
    # ```
    def initialize(@duration = nil, @segment = nil, @comment = nil, byterange = nil, program_date_time = nil)
      @byterange = ByteRange.parse(byterange)
      @program_date_time = TimeItem.parse(program_date_time)
    end

    # Setter for the `byterange` property.
    #
    # Allows setting the byterange attribute using a `ByteRange` object, a NamedTuple, or a string.
    # The input is parsed using `ByteRange.parse`.
    #
    # Example:
    #
    # ```crystal
    # item = SegmentItem.new
    # item.byterange = ByteRange.new(length: 4500, start: 600)
    # item.byterange = {length: 4500, start: 600}
    # item.byterange = "4500@600"
    #
    # item.byterange
    # # => #<M3U8::ByteRange:0x784ba59ea7e0 @length=4500, @start=600>
    # ```
    def byterange=(byterange)
      @byterange = ByteRange.parse(byterange)
    end

    # Setter for the `program_date_time` property.
    #
    # Allows setting the `program_date_time` attribute using a `TimeItem`, `Time`, or [ISO-8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf) string.
    # The input is parsed using `TimeItem.parse`.
    #
    # Example:
    #
    # ```crystal
    # item = SegmentItem.new
    # item.program_date_time = TimeItem.new("2010-02-19T14:54:23Z")
    # item.program_date_time = TimeItem.new(Time.iso8601("2010-02-19T14:54:23.031Z"))
    # item.program_date_time = Time.parse_iso8601("2010-02-19T14:54:23.031Z")
    # item.program_date_time = "2010-02-19T14:54:23.031Z"
    #
    # item.program_date_time
    # # => #<M3U8::TimeItem:0x7f5e17fedea0 @time=2010-02-19 14:54:23.031000000 UTC>
    # ```
    def program_date_time=(time)
      @program_date_time = TimeItem.parse(time)
    end

    # Returns the string representation of the segment, including the `EXTINF` tag,
    # an optional `EXT-X-BYTERANGE` tag, an optional `EXT-X-PROGRAM-DATE-TIME` tag, and the segment URI.
    #
    # The components are joined with newline characters.
    #
    # Example:
    #
    # ```txt
    # options = {
    #   duration:  10.991,
    #   segment:   "test.ts",
    #   comment:   "anything",
    #   byterange: "4500@600",
    # }
    # SegmentItem.new(options).to_s
    # # => "#EXTINF:10.991,anything\n" +
    # #    "#EXT-X-BYTERANGE:4500@600\n" +
    # #    "test.ts"
    #
    # SegmentItem.new(10.991, "test.ts", "anything", "4500@600", "2010-02-19T14:54:23.031Z").to_s
    # # => "#EXTINF:10.991,anything\n" +
    # #    "#EXT-X-BYTERANGE:4500@600\n" +
    # #    "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z\n" +
    # #    "test.ts"
    # ```
    def to_s
      attributes.join('\n')
    end

    private def attributes
      [
        inf_format,
        byterange_format,
        program_date_time_format,
        segment,
      ].compact
    end

    private def inf_format
      "#EXTINF:#{duration},#{comment}"
    end

    private def byterange_format
      "#EXT-X-BYTERANGE:#{byterange.to_s}" unless byterange.empty?
    end

    private def program_date_time_format
      program_date_time.to_s unless program_date_time.empty?
    end
  end
end
