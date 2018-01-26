module M3U8
  # PlaybackStart represents a #EXT-X-START tag and attributes
  class PlaybackStart
    include Concern

    property time_offset : Float64
    property precise : Bool?

    # ```
    # text = "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES"
    # PlaybackStart.parse(text)
    # # => #<M3U8::PlaybackStart......>
    # ```
    def self.parse(text)
      attributes = parse_attributes(text)
      new(
        time_offset: attributes["TIME-OFFSET"],
        precise: parse_boolean(attributes["PRECISE"]?),
      )
    end

    # ```
    # options = {
    #   time_offset: -12.9,
    #   precise: true
    # }
    # PlaybackStart.new(options)
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        time_offset: params[:time_offset],
        precise: params[:precise]?
      )
    end

    # ```
    # time_offset = -12.9
    # precise = true
    # PlaybackStart.new(time_offset)
    # PlaybackStart.new(time_offset, precise)
    # ```
    def initialize(time_offset, @precise = nil)
      @time_offset = time_offset.to_f
    end

    # ```
    # options = {
    #   time_offset: -12.9,
    #   precise: true
    # }
    # PlaybackStart.new(options).to_s
    # # => "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES"
    # ```
    def to_s
      "#EXT-X-START:#{attributes.join(',')}"
    end

    private def attributes
      [
        time_offset_format,
        precise_format
      ].compact
    end

    private def time_offset_format
      "TIME-OFFSET=#{time_offset}"
    end

    private def precise_format
      "PRECISE=#{parse_yes_no(precise)}" unless precise.nil?
    end
  end
end

