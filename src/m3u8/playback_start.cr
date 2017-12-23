module M3U8
  # PlaybackStart represents a #EXT-X-START tag and attributes
  class PlaybackStart
    property time_offset : Float64
    property precise : Bool?

    def initialize(params = NamedTuple.new)
      @time_offset = params[:time_offset]
      @precise = params[:precise]?
    end

    # def parse(text)
    #   attributes = parse_attributes(text)
    #   @time_offset = attributes['TIME-OFFSET'].to_f
    #   precise = attributes['PRECISE']
    #   @precise = parse_yes_no(precise) unless precise.nil?
    # end

    def to_s
      "#EXT-X-START:#{formatted_attributes.join(',')}"
    end

    def formatted_attributes
      [
        time_offset_format,
        precise_format
      ].compact
    end

    private def time_offset_format
      "TIME-OFFSET=#{time_offset}"
    end

    private def precise_format
      "PRECISE=#{precise.not_nil!.to_yes_no}" unless precise.nil?
    end
  end
end

