module M3U8
  # PlaybackStart represents a #EXT-X-START tag and attributes
  class PlaybackStart
    property time_offset : Float64
    property precise : Bool?

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        time_offset: params[:time_offset],
        precise: params[:precise]?
      )
    end

    def initialize(time_offset, @precise = nil)
      @time_offset = time_offset.not_nil!.to_f
    end

    # def parse(text)
    #   attributes = parse_attributes(text)
    #   @time_offset = attributes['TIME-OFFSET'].to_f
    #   precise = attributes['PRECISE']
    #   @precise = parse_yes_no(precise) unless precise.nil?
    # end

    def to_s
      "#EXT-X-START:#{attributes.join(',')}"
    end

    def attributes
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

