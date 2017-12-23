module M3U8
  # SegmentItem represents EXTINF attributes with the URI that follows,
  # optionally allowing an EXT-X-BYTERANGE tag to be set.
  class SegmentItem
    property duration : Float64
    property segment : String
    property comment : String?
    property byterange : ByteRange?
    property program_date_time : TimeItem?

    def initialize(params = NamedTuple.new)
      @duration = params[:duration]
      @segment = params[:segment]
      @comment = params[:comment]?
      @byterange = parse_byterange(params)
      @program_date_time = parse_program_date_time(params)
    end

    def to_s
      formatted_attributes.join('\n')
    end

    def formatted_attributes
      [
        inf_format,
        byterange_format,
        program_date_time_format,
        segment,
      ].compact
    end

    private def parse_program_date_time(params)
      item = params[:program_date_time]?

      case item
      when String, Time
        TimeItem.new item
      when TimeItem
        item
      end
    end

    private def parse_byterange(params)
      item = params[:byterange]?
      ByteRange.new(item) unless item.nil?
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
