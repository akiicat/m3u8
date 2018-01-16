module M3U8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    
    include Concern

    property duration : Float64?
    property segment : String?
    property comment : String?
    getter byterange : ByteRange?
    getter program_date_time : TimeItem?

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        duration: params[:duration]?,
        segment: params[:segment]?,
        comment: params[:comment]?,
        byterange: params[:byterange]?,
        program_date_time: params[:program_date_time]?,
      )
    end

    def initialize(@duration, @segment, @comment = nil, byterange = nil, program_date_time = nil)
      @byterange = parse_byterange(byterange)
      @program_date_time = parse_time_item(program_date_time)
    end

    def byterange=(byterange)
      @byterange = parse_byterange(byterange)
    end

    def program_date_time=(time)
      @program_date_time = parse_time_item(time)
    end

    def to_s
      attributes.join('\n')
    end

    def attributes
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
      "#EXT-X-BYTERANGE:#{byterange.to_s}" unless byterange.nil?
    end

    private def program_date_time_format
      program_date_time.to_s unless program_date_time.nil?
    end
  end
end
