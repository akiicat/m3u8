module M3U8
  # `PlaybackStart` represents the `EXT-X-START` tag used in HLS playlists.
  #
  # The `EXT-X-START` tag specifies the preferred starting point for playback of
  # a Media Playlist. It includes the following attributes:
  #
  #   - **TIME-OFFSET** (required): A decimal number representing the offset (in seconds)
  #     from the beginning of the playlist where playback should start. A negative
  #     value indicates that playback should begin a certain time before the end of
  #     the playlist.
  #   - **PRECISE** (optional): A boolean value that indicates whether the time offset is
  #     precise. This attribute is represented as "YES" for true and "NO" for false.
  #
  # According to [RFC 8216, Section 4.3.5.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.5.2),
  # the tag is formatted as follows:
  #
  # ```txt
  # #EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES
  # ```
  #
  # This class provides methods to parse an `EXT-X-START` tag from a text string, create
  # a new instance using a NamedTuple of parameters, and output the tag as a properly
  # formatted string.
  class PlaybackStart
    include Concern

    # The time offset in seconds, indicating the preferred start point.
    property time_offset : Float64

    # An optional flag indicating whether the time offset is precise.
    property precise : Bool?

    # Parses a text string representing an `EXT-X-START` tag and returns a new `PlaybackStart` instance.
    #
    # It extracts the *TIME-OFFSET* and *PRECISE* attributes from the tag line using the
    # `parse_attributes` helper (defined in `M3U8::Concern`), converts them to the appropriate types
    # (with precise parsed as a boolean), and creates a new instance.
    #
    # Example:
    #
    # ```
    # text = "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES"
    # PlaybackStart.parse(text)
    # # => #<M3U8::PlaybackStart:0x7acbac72a2a0 @precise=true, @time_offset=-12.9>
    # ```
    def self.parse(text)
      attributes = parse_attributes(text)
      new(
        time_offset: attributes["TIME-OFFSET"],
        precise: parse_boolean(attributes["PRECISE"]?),
      )
    end

    # Constructs a new `PlaybackStart` instance from a NamedTuple of parameters.
    #
    # The NamedTuple can include:
    #   - `time_offset` (Float64 or convertible to Float64): The preferred start offset.
    #   - `precise` (Bool): The precision flag.
    #
    # Example:
    # ```
    # options = {
    #   time_offset: -12.9,
    #   precise:     true,
    # }
    # PlaybackStart.new(options)
    # # => #<M3U8::PlaybackStart:0x7a950cc56270 @precise=true, @time_offset=-12.9>
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        time_offset: params[:time_offset],
        precise: params[:precise]?
      )
    end

    # Initializes a new `PlaybackStart` instance.
    #
    # The time_offset is converted to a Float, and the precise flag is stored as provided.
    #
    # Examples:
    # ```
    # time_offset = -12.9
    # precise = true
    # PlaybackStart.new(time_offset)          # => #<M3U8::PlaybackStart:0x7a8a1a6fd240 @precise=nil, @time_offset=-12.9>
    # PlaybackStart.new(time_offset, precise) # => #<M3U8::PlaybackStart:0x7a8a1a6fd210 @precise=true, @time_offset=-12.9>
    # ```
    def initialize(time_offset, @precise = nil)
      @time_offset = time_offset.to_f
    end

    # Returns the string representation of the `EXT-X-START` tag.
    #
    # It assembles the formatted attributes and prefixes them with `#EXT-X-START:`.
    #
    # Example:
    #
    # ```txt
    # options = {
    #   time_offset: -12.9,
    #   precise:     true,
    # }
    # PlaybackStart.new(options).to_s
    # # => "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES"
    #
    # PlaybackStart.new(time_offset: -12.9).to_s
    # # => "#EXT-X-START:TIME-OFFSET=-12.9"
    # ```
    def to_s
      "#EXT-X-START:#{attributes.join(',')}"
    end

    private def attributes
      [
        time_offset_format,
        precise_format,
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
