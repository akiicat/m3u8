module M3U8
  # MediaItem represents a set of EXT-X-MEDIA attributes

  # `MediaItem` represents a set of attributes for the `EXT-X-MEDIA` tag in an HLS playlist.
  #
  # The `EXT-X-MEDIA` tag (defined in [RFC 8216, Section 4.3.4.1](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.1)) is used in HLS Master Playlists
  # to associate media renditions with alternative tracks (e.g., audio or subtitles). It carries
  # information such as the media type, group identifier, language, human-readable name, and
  # additional parameters like auto-selection, default status, and more.
  #
  # The following attributes are typically included:
  #   - **TYPE**: Indicates the type of media (e.g., AUDIO, VIDEO, SUBTITLES, CLOSED-CAPTIONS).
  #   - **GROUP-ID**: A string that groups related renditions together.
  #   - **LANGUAGE**: A language tag (as defined in [RFC 5646](https://datatracker.ietf.org/doc/html/rfc5646)) representing the primary language.
  #   - **ASSOC-LANGUAGE**: An associated language tag for alternate language roles.
  #   - **NAME**: A human-readable name for the rendition.
  #   - **URI**: An optional URI that points to a separate Media Playlist for this rendition.
  #   - **AUTOSELECT**: A flag indicating whether the rendition should be automatically selected.
  #   - **DEFAULT**: A flag indicating whether the rendition is the default selection.
  #   - **FORCED**: A flag for subtitles that indicates whether the rendition is forced.
  #   - **INSTREAM-ID**: For closed-caption renditions, an identifier for the specific caption channel.
  #   - **CHARACTERISTICS**: Additional characteristics for the rendition, as a comma-separated list.
  #   - **CHANNELS**: For audio, a string indicating the number of channels and their order.
  #
  # Example `EXT-X-MEDIA` tag:
  #
  # ```txt
  # #EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aac",LANGUAGE="en",NAME="English",AUTOSELECT=YES,DEFAULT=YES,URI="eng_audio.m3u8"
  # ```
  #
  # This class provides methods to parse such a tag from a text string, create a new instance
  # using a NamedTuple of parameters, and output the tag as a properly formatted string.
  class MediaItem
    include Concern

    property type : String?
    property group_id : String?
    property language : String?
    property assoc_language : String?
    property name : String?
    property uri : String?
    property autoselect : Bool?
    property default : Bool?
    property forced : Bool?
    property instream_id : String?
    property characteristics : String?
    property channels : String?

    # Parses a text string representing an `EXT-X-MEDIA` tag and returns a new `MediaItem` instance.
    #
    # The method extracts key/value pairs using `parse_attributes` (from `M3U8::Concern`) and
    # converts them to appropriate types (e.g., booleans using `parse_boolean`).
    #
    # Example:
    #
    # ```crystal
    # text = %(#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aac",LANGUAGE="en",NAME="English",AUTOSELECT=YES,DEFAULT=YES,URI="eng_audio.m3u8")
    # MediaItem.parse(text)
    # # => #<M3U8::MediaItem:0x7cd7249453f0
    # #     @assoc_language=nil,
    # #     @autoselect=true,
    # #     @channels=nil,
    # #     @characteristics=nil,
    # #     @default=true,
    # #     @forced=nil,
    # #     @group_id="aac",
    # #     @instream_id=nil,
    # #     @language="en",
    # #     @name="English",
    # #     @type="AUDIO",
    # #     @uri="eng_audio.m3u8">
    # ```
    def self.parse(text)
      attributes = parse_attributes(text)
      new(
        type: attributes["TYPE"]?,
        group_id: attributes["GROUP-ID"]?,
        language: attributes["LANGUAGE"]?,
        assoc_language: attributes["ASSOC-LANGUAGE"]?,
        name: attributes["NAME"]?,
        autoselect: parse_boolean(attributes["AUTOSELECT"]?),
        default: parse_boolean(attributes["DEFAULT"]?),
        forced: parse_boolean(attributes["FORCED"]?),
        uri: attributes["URI"]?,
        instream_id: attributes["INSTREAM-ID"]?,
        characteristics: attributes["CHARACTERISTICS"]?,
        channels: attributes["CHANNELS"]?,
      )
    end

    # Constructs a new `MediaItem` instance from a NamedTuple of parameters.
    #
    # The NamedTuple can include keys corresponding to the `EXT-X-MEDIA` attributes:
    # `type`, `group_id`, `language`, `assoc_language`, `name`, `uri`, `autoselect`, `default`, `forced`, `instream_id`, `characteristics`, `channels`.
    #
    # Example:
    #
    # ```crystal
    # options = {
    #   type: "AUDIO",
    #   group_id: "aac",
    #   language: "en",
    #   name: "English",
    #   autoselect: true,
    #   default: true,
    #   uri: "eng_audio.m3u8",
    # }
    # MediaItem.new(options)
    # # => #<M3U8::MediaItem:0x7b19ac8eb2d0
    # #     @assoc_language=nil,
    # #     @autoselect=true,
    # #     @channels=nil,
    # #     @characteristics=nil,
    # #     @default=true,
    # #     @forced=nil,
    # #     @group_id="aac",
    # #     @instream_id=nil,
    # #     @language="en",
    # #     @name="English",
    # #     @type="AUDIO",
    # #     @uri="eng_audio.m3u8">
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        type: params[:type]?,
        group_id: params[:group_id]?,
        language: params[:language]?,
        assoc_language: params[:assoc_language]?,
        name: params[:name]?,
        uri: params[:uri]?,
        autoselect: params[:autoselect]?,
        default: params[:default]?,
        forced: params[:forced]?,
        instream_id: params[:instream_id]?,
        characteristics: params[:characteristics]?,
        channels: params[:channels]?,
      )
    end

    # Initializes a new `MediaItem` instance.
    #
    # All attributes default to nil if not provided.
    #
    # Examples:
    #
    # ```crystal
    # MediaItem.new(
    #   type: "AUDIO",
    #   group_id: "aac",
    #   language: "en",
    #   name: "English",
    #   autoselect: true,
    #   default: true,
    #   uri: "eng_audio.m3u8",
    # )
    # # => #<M3U8::MediaItem:0x7ea38df181b0
    # #     @assoc_language=nil,
    # #     @autoselect=true,
    # #     @channels=nil,
    # #     @characteristics=nil,
    # #     @default=true,
    # #     @forced=nil,
    # #     @group_id="aac",
    # #     @instream_id=nil,
    # #     @language="en",
    # #     @name="English",
    # #     @type="AUDIO",
    # #     @uri="eng_audio.m3u8">
    # ```
    def initialize(@type = nil, @group_id = nil, @language = nil, @assoc_language = nil, @name = nil,
                   @uri = nil, @autoselect = nil, @default = nil, @forced = nil, @instream_id = nil,
                   @characteristics = nil, @channels = nil)
    end

    # Returns the string representation of the `EXT-X-MEDIA` tag.
    #
    # The output is constructed by joining the formatted attributes with commas,
    # and then prefixing the result with `#EXT-X-MEDIA:`.
    #
    # Examples:
    #
    # ```txt
    # MediaItem.new(
    #   type: "AUDIO",
    #   group_id: "aac",
    #   language: "en",
    #   name: "English",
    #   autoselect: true,
    #   default: true,
    #   uri: "eng_audio.m3u8",
    # ).to_s
    # # => "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"aac\",LANGUAGE=\"en\",NAME=\"English\",AUTOSELECT=YES,DEFAULT=YES,URI=\"eng_audio.m3u8\""
    # ```
    def to_s
      "#EXT-X-MEDIA:#{attributes.join(',')}"
    end

    private def attributes
      [
        type_format,
        group_id_format,
        language_format,
        assoc_language_format,
        name_format,
        autoselect_format,
        default_format,
        uri_format,
        forced_format,
        instream_id_format,
        characteristics_format,
        channels_format,
      ].compact
    end

    private def type_format
      %(TYPE=#{type})
    end

    private def group_id_format
      %(GROUP-ID="#{group_id}")
    end

    private def language_format
      %(LANGUAGE="#{language}") unless language.nil?
    end

    private def assoc_language_format
      %(ASSOC-LANGUAGE="#{assoc_language}") unless assoc_language.nil?
    end

    private def name_format
      %(NAME="#{name}")
    end

    private def uri_format
      %(URI="#{uri}") unless uri.nil?
    end

    private def autoselect_format
      %(AUTOSELECT=#{parse_yes_no(autoselect)}) unless autoselect.nil?
    end

    private def default_format
      %(DEFAULT=#{parse_yes_no(default)}) unless default.nil?
    end

    private def forced_format
      %(FORCED=#{parse_yes_no(forced)}) unless forced.nil?
    end

    private def instream_id_format
      %(INSTREAM-ID="#{instream_id}") unless instream_id.nil?
    end

    private def characteristics_format
      %(CHARACTERISTICS="#{characteristics}") unless characteristics.nil?
    end

    private def channels_format
      %(CHANNELS="#{channels}") unless channels.nil?
    end
  end
end
