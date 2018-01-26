module M3U8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    include Concern

    property duration : Float64?
    property segment : String?
    property comment : String?
    getter byterange : ByteRange
    getter program_date_time : TimeItem

    # ```
    # options = {
    #   duration: 10.991,
    #   segment: "test.ts",
    #   comment: "anything",
    #   byterange: { length: 4500, start: 600 }
    # }
    # SegmentItem.new(options)
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

    # ```
    # SegmentItem.new
    # ```
    def initialize(@duration = nil, @segment = nil, @comment = nil, byterange = nil, program_date_time = nil)
      @byterange = parse_byterange(byterange)
      @program_date_time = parse_time_item(program_date_time)
    end

    # ```
    # item = SegmentItem.new
    # item.byterange = ByteRange.new(length: 4500, start: 600)
    # item.byterange = { length: 4500, start: 600 }
    # item.byterange = "4500@600"
    # item.byterange # => #<M3U8::ByteRange......>
    # ```
    def byterange=(byterange)
      @byterange = parse_byterange(byterange)
    end

    # ```
    # item = SegmentItem.new
    # item.program_date_time = TimeItem.new("2010-02-19T14:54:23Z")
    # item.program_date_time = TimeItem.new(Time.iso8601("2010-02-19T14:54:23.031Z"))
    # item.program_date_time = Time.iso8601("2010-02-19T14:54:23.031Z")
    # item.program_date_time = "2010-02-19T14:54:23.031Z"
    # item.program_date_time # => #<M3U8::TimeItem......>
    # ```
    def program_date_time=(time)
      @program_date_time = parse_time_item(time)
    end

    # ```
    # options = {
    #   duration: 10.991,
    #   segment: "test.ts",
    #   comment: "anything",
    #   byterange: { length: 4500, start: 600 }
    # }
    # SegmentItem.new(options).to_s
    # # => %(#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500@600\ntest.ts)
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

