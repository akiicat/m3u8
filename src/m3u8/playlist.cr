module M3U8
  # `Playlist` represents an m3u8 playlist, which can be either a Master Playlist or a Media Playlist.
  #
  # In an HLS playlist, as defined in [RFC 8216](https://tools.ietf.org/html/rfc8216),
  # the file begins with the `EXTM3U` tag and may
  # contain a variety of global and segment-specific tags. A Master Playlist includes entries
  # for different Variant Streams (using `EXT-X-STREAM-INF` or `EXT-X-I-FRAME-STREAM-INF` tags),
  # while a Media Playlist lists the media segments (with `EXTINF`, `EXT-X-BYTERANGE`, etc.).
  #
  # **Basic Tags:**
  # - `EXTM3U`: `Playlist`
  # - `EXT-X-VERSION`: `Playlist#version`
  #
  # **Media Playlist Tags:**
  # - `EXT-X-TARGETDURATION`: `Playlist#target`
  # - `EXT-X-MEDIA-SEQUENCE`: `Playlist#sequence`
  # - `EXT-X-DISCONTINUITY-SEQUENCE`: `Playlist#discontinuity_sequence`
  # - `EXT-X-ENDLIST`: `Playlist.footer`
  # - `EXT-X-PLAYLIST-TYPE`: `Playlist#type`
  # - `EXT-X-I-FRAMES-ONLY`: `Playlist#iframes_only`
  # - `EXT-X-ALLOW-CACHE`: `Playlist#cache` (deprecated in protocol version 7)
  #
  # **Media Segment Tags:**
  # - `EXTINF`: `SegmentItem`
  # - `EXT-X-BYTERANGE`: `ByteRange`
  # - `EXT-X-DISCONTINUITY`: `DiscontinuityItem`
  # - `EXT-X-KEY`: `KeyItem`
  # - `EXT-X-MAP`: `MapItem`
  # - `EXT-X-PROGRAM-DATE-TIME`: `TimeItem`
  # - `EXT-X-DATERANGE`: `DateRangeItem`
  #
  # **Master Playlist tags:**
  # - `EXT-X-MEDIA`: `MediaItem`
  # - `EXT-X-STREAM-INF`: `PlaylistItem` with `Playlist#iframe` set to `false`
  # - `EXT-X-I-FRAME-STREAM-INF`: `PlaylistItem` with `Playlist#iframe` set to `true`
  # - `EXT-X-SESSION-DATA`: `SessionDataItem`
  # - `EXT-X-SESSION-KEY`: `SessionKeyItem`
  #
  # **Media or Master Playlist Tags:**
  # - `EXT-X-INDEPENDENT-SEGMENTS`: `Playlist#independent_segments`
  # - `EXT-X-START`: `PlaybackStart`
  #
  # This class maintains various playlist-wide properties:
  #   - **master**:                  Indicates whether the playlist is a Master Playlist.
  #   - **version**:                 The protocol compatibility version (EXT-X-VERSION).
  #   - **cache**:                   Whether caching is allowed (`EXT-X-ALLOW-CACHE` tag was removed in protocol version 7).
  #   - **discontinuity_sequence**:  The discontinuity sequence number (EXT-X-DISCONTINUITY-SEQUENCE).
  #   - **type**:                    The playlist type (e.g., VOD or EVENT, from EXT-X-PLAYLIST-TYPE).
  #   - **target**:                  The target duration for media segments (EXT-X-TARGETDURATION).
  #   - **sequence**:                The Media Sequence Number (EXT-X-MEDIA-SEQUENCE).
  #   - **iframes_only**:            Indicates if the playlist is an I-frame only playlist (EXT-X-I-FRAMES-ONLY).
  #   - **independent_segments**:    Flag indicating if segments can be independently decoded (`EXT-X-INDEPENDENT-SEGMENTS`).
  #   - **live**:                    A boolean flag indicating whether the playlist is live (no endlist tag).
  #   - **items**:                   An array of playlist items (which can be SegmentItem, PlaylistItem, etc.).
  #
  # The class provides methods to create a new `Playlist`, to parse a playlist
  # from a string input, and to generate the complete playlist as a string by combining `header`, `body`,
  # and `footer` components.
  #
  # Examples:
  #
  # Creating a new Playlist with specific parameters:
  # ```
  # options = {
  #   version:                7,
  #   cache:                  false,
  #   target:                 12,
  #   sequence:               1,
  #   discontinuity_sequence: 2,
  #   type:                   "VOD",
  #   independent_segments:   true,
  # }
  # playlist = Playlist.new(options)
  # playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
  # playlist.items << SegmentItem.new(duration: 9.891, segment: "test_02.ts")
  # playlist.items << SegmentItem.new(duration: 10.556, segment: "test_03.ts")
  # playlist.items << SegmentItem.new(duration: 8.790, segment: "test_04.ts")
  # playlist.duration # => 40.227999999999994
  # playlist.to_s
  # # => "#EXTM3U\n" +
  # #    "#EXT-X-PLAYLIST-TYPE:VOD\n" +
  # #    "#EXT-X-VERSION:7\n" +
  # #    "#EXT-X-INDEPENDENT-SEGMENTS\n" +
  # #    "#EXT-X-MEDIA-SEQUENCE:1\n" +
  # #    "#EXT-X-DISCONTINUITY-SEQUENCE:2\n" +
  # #    "#EXT-X-ALLOW-CACHE:NO\n" +
  # #    "#EXT-X-TARGETDURATION:12\n" +
  # #    "#EXTINF:10.991,\n" +
  # #    "test_01.ts\n" +
  # #    "#EXTINF:9.891,\n" +
  # #    "test_02.ts\n" +
  # #    "#EXTINF:10.556,\n" +
  # #    "test_03.ts\n" +
  # #    "#EXTINF:8.79,\n" +
  # #    "test_04.ts\n" +
  # #    "#EXT-X-ENDLIST\n"
  # ```
  #
  # Parsing a complete playlist string:
  # ```
  # m3u8_string = "#EXTM3U\n#EXT-X-VERSION:7\n#EXT-X-TARGETDURATION:12\n..."
  # Playlist.parse(m3u8_string)
  # # => #<M3U8::Playlist ...>
  # ```
  class Playlist
    include Concern

    property master : Bool?

    property version : Int32?
    property cache : Bool?
    property discontinuity_sequence : Int32?
    property type : String?

    property target : Float64
    property sequence : Int32

    # Specifies whether the playlist is an I-frame only playlist.
    # If set to true, the playlist header will include the `EXT-X-I-FRAMES-ONLY` tag,
    # indicating that the playlist contains only I-frame segments (useful for trick play).
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new
    # playlist.iframes_only = true
    # playlist.header
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-I-FRAMES-ONLY\n" +
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" +
    # #    "#EXT-X-TARGETDURATION:10"
    #
    # playlist.iframes_only = false
    # playlist.header
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" +
    # #    "#EXT-X-TARGETDURATION:10"
    #
    # playlist.iframes_only = nil
    # playlist.header
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" +
    # #    "#EXT-X-TARGETDURATION:10"
    # ```
    property iframes_only : Bool

    # When set to true, the playlist header will include the `EXT-X-INDEPENDENT-SEGMENTS` tag.
    #
    # This tag indicates that each Media Segment in the playlist can be independently decoded,
    # which is important for certain playback scenarios in HLS.
    #
    # If the property is `false` or `nil`, the `EXT-X-INDEPENDENT-SEGMENTS` tag will not be output.
    #
    # Example:
    # ```
    # playlist = Playlist.new
    # playlist.independent_segments = true
    # playlist.header
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-INDEPENDENT-SEGMENTS\n" +
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" +
    # #    "#EXT-X-TARGETDURATION:10"
    #
    # playlist.independent_segments = false
    # playlist.header
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" +
    # #    "#EXT-X-TARGETDURATION:10"
    #
    # playlist.independent_segments = nil
    # playlist.header
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" +
    # #    "#EXT-X-TARGETDURATION:10"
    # ```
    property independent_segments : Bool
    property live : Bool
    property items : Array(Items)

    # ```
    # Constructs a new Playlist instance from a NamedTuple of parameters.
    #
    # The NamedTuple may include keys for properties such as:
    #   :master, :version, :cache, :discontinuity_sequence, :type,
    #   :target, :sequence, :iframes_only, :independent_segments, :live, and :items.
    #
    # Example:
    # ```
    # options = {
    #   version:                7,
    #   cache:                  false,
    #   target:                 12,
    #   sequence:               1,
    #   discontinuity_sequence: 2,
    #   type:                   "VOD",
    #   independent_segments:   true,
    # }
    # Playlist.new(options)
    # # => #<M3U8::Playlist:0x79adbb379540
    # #     @cache=false,
    # #     @discontinuity_sequence=2,
    # #     @iframes_only=false,
    # #     @independent_segments=true,
    # #     @items=[],
    # #     @live=false,
    # #     @master=nil,
    # #     @sequence=1,
    # #     @target=12.0,
    # #     @type="VOD",
    # #     @version=7>
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        master: params[:master]?,
        version: params[:version]?,
        cache: params[:cache]?,
        discontinuity_sequence: params[:discontinuity_sequence]?,
        type: params[:type]?,
        target: params[:target]?,
        sequence: params[:sequence]?,
        iframes_only: params[:iframes_only]?,
        independent_segments: params[:independent_segments]?,
        live: params[:live]?,
        items: params[:items]?,
      )
    end

    # Initializes a new Playlist instance.
    #
    # Example:
    # ```
    # Playlist.new(
    #   version: 7,
    #   cache: false,
    #   target: 12,
    #   sequence: 1,
    #   discontinuity_sequence: 2,
    #   type: "VOD",
    #   independent_segments: true,
    # )
    # # => #<M3U8::Playlist:0x78d37cb334d0
    # #     @cache=false,
    # #     @discontinuity_sequence=2,
    # #     @iframes_only=false,
    # #     @independent_segments=true,
    # #     @items=[],
    # #     @live=false,
    # #     @master=nil,
    # #     @sequence=1,
    # #     @target=12.0,
    # #     @type="VOD",
    # #     @version=7>
    # ```
    def initialize(@master = nil, @version = nil, @cache = nil, @discontinuity_sequence = nil, @type = nil,
                   target = nil, sequence = nil, iframes_only = nil, independent_segments = nil, live = nil,
                   items = nil)
      @target = default_params(:target).to_f
      @sequence = default_params(:sequence)
      @iframes_only = default_params(:iframes_only)
      @independent_segments = default_params(:independent_segments)
      @live = default_params(:live)
      @items = default_params(:items)
    end

    # Generates the *CODECS* attribute string for the playlist.
    #
    # This method instantiates a `Codecs` object with the given options and returns its
    # string representation. The *CODECS* attribute lists the codecs used in the media, such as
    # "avc1.66.30,mp4a.40.2". For details on how the codecs are determined, refer to the `Codecs` class.
    #
    # Example:
    #
    # ```
    # options = {
    #   profile:     "baseline",
    #   level:       3.0,
    #   audio_codec: "aac-lc",
    # }
    # Playlist.codecs(options) # => "avc1.66.30,mp4a.40.2"
    # ```
    def self.codecs(options = NamedTuple.new)
      Codecs.new(options).to_s
    end

    # Parses a playlist string into a `Playlist` instance.
    #
    # Example:
    #
    # ```
    # m3u8_string = "#EXTM3U\n#EXT-X-VERSION:7\n#EXT-X-TARGETDURATION:12\n..."
    # Playlist.parse(m3u8_string)
    # # => #<M3U8::Playlist ...>
    # ```
    def self.parse(input)
      Parser.read(input)
    end

    # Returns `true` if the playlist is considered live.
    #
    # - For a Master Playlist, live is always false.
    # - For a Media Playlist, the live property is determined by the parsed content.
    #
    # Example:
    #
    # ```
    # playlist = Playlist.new(live: true)
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
    # playlist.live? # => true
    # ```
    def live?
      master? ? false : live
    end

    # Returns `true` if the playlist is a Master Playlist.
    #
    # If the `master` property is explicitly set (i.e. not nil), its value is returned.
    # Otherwise, the playlist type is inferred based on the items it contains:
    # - If there are no `PlaylistItem` and no `SegmentItem` entries, it returns false.
    # - If there is at least one `PlaylistItem` entry, the playlist is considered a Master Playlist.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new(master: true)
    # playlist.master? # => true
    #
    # playlist = Playlist.new
    # playlist.master? # => false
    #
    # playlist = Playlist.new
    # playlist.items << PlaylistItem.new(program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url")
    # playlist.master? # => true
    #
    # playlist = Playlist.new
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test.ts")
    # playlist.master? # => false
    # ```
    def master?
      return master unless master.nil?
      (playlist_size.zero? && segment_size.zero?) ? false : playlist_size > 0
    end

    # Validates the playlist.
    #
    # Returns `true` if either the number of `PlaylistItem` entries or `SegmentItem` entries is zero.
    # Otherwise, it returns `false`, indicating a potential mismatch in playlist types.
    #
    # Example:
    # ```
    # playlist = Playlist.new
    # playlist.items << PlaylistItem.new(program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url")
    # playlist.valid? # => true
    #
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test.ts")
    # playlist.valid? # => false
    # ```
    def valid?
      (playlist_size.zero? || segment_size.zero?) ? true : false
    end

    # Validates the playlist and raises an `Error::PlaylistType` error if it is invalid.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new
    # playlist.items << PlaylistItem.new(program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url")
    # playlist.valid! # => nil
    #
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test.ts")
    # playlist.valid! # => raises M3U8::Error::PlaylistType
    # ```
    def valid!
      raise Error::PlaylistType.new("Playlist is invalid.") unless valid?
    end

    # Calculates the total duration of the playlist by summing the durations of all `SegmentItems`.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
    # playlist.items << SegmentItem.new(duration: 9.891, segment: "test_02.ts")
    # playlist.items << SegmentItem.new(duration: 10.556, segment: "test_03.ts")
    # playlist.items << SegmentItem.new(duration: 8.790, segment: "test_04.ts")
    # playlist.duration          # => 40.227999999999994
    # playlist.duration.round(3) # => 40.228
    # ```
    def duration
      items.reduce(0.0) do |acc, item|
        duration = item.duration if item.is_a?(SegmentItem)
        duration ||= 0.0
        acc + duration
      end
    end

    # ```
    # playlist = Playlist.new
    #
    # options = {program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3"}
    # playlist.items << PlaylistItem.new(options)
    #
    # playlist.to_s
    # # => %(#EXTM3U\n) \
    # %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34",) \
    # %(BANDWIDTH=6400\nplaylist_url\n)
    # ```

    # Returns the complete playlist as a string.
    #
    # The output is generated by concatenating the `header`, `body`, and `footer` sections
    # of the playlist, separated by newline characters.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new
    # playlist.items << PlaylistItem.new(program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3")
    # playlist.to_s
    # # => "#EXTM3U\n" +
    # #    "#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS=\"mp4a.40.34\",BANDWIDTH=6400\n" +
    # #    "playlist_url\n"
    # ```
    def to_s
      attributes.join('\n') + "\n"
    end

    # Returns the header section of the playlist as a string.
    #
    # The header tags based on whether the playlist is a Master or Media Playlist.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new(master: true, version: 6, independent_segments: true)
    # playlist.header
    # # => "#EXTM3U\n" \
    # #    "#EXT-X-VERSION:6\n" \
    # #    "#EXT-X-INDEPENDENT-SEGMENTS"
    #
    # playlist = Playlist.new(version: 6, independent_segments: true)
    # playlist.header
    # # => "#EXTM3U\n" \
    # #    "#EXT-X-VERSION:6\n" \
    # #    "#EXT-X-INDEPENDENT-SEGMENTS\n" \
    # #    "#EXT-X-MEDIA-SEQUENCE:0\n" \
    # #    "#EXT-X-TARGETDURATION:10"
    # ```
    def header
      header_attributes.join('\n')
    end

    # Returns the body section of the playlist as a string.
    #
    # The body consists of all the items (segments or playlist entries) that have been added.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new(version: 6, independent_segments: true)
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test.ts")
    # playlist.body
    # # => "#EXTINF:10.991,\n"
    # #    "test.ts"
    # ```
    def body
      body_attributes.join('\n')
    end

    # Returns the footer section of the playlist as a string.
    #
    # For Video On Demand (VOD) playlists, the footer typically includes the
    # `#EXT-X-ENDLIST` tag, which signals that no additional segments will be added.
    # This tag is omitted for `live` playlists or `master` playlists.
    #
    # Examples:
    #
    # ```
    # playlist = Playlist.new(version: 6, independent_segments: true)
    # playlist.footer # => "#EXT-X-ENDLIST"
    #
    # playlist = Playlist.new(live: true)
    # playlist.footer # => ""
    #
    # playlist = Playlist.new(master: true)
    # playlist.footer # => ""
    # ```
    def footer
      footer_attributes.join('\n')
    end

    private def attributes
      valid!
      [
        header_attributes,
        body_attributes,
        footer_attributes,
      ].flatten
    end

    private def header_attributes
      master? ? master_header_attributes : media_header_attributes
    end

    private def body_attributes
      items.map { |item| item.to_s }
    end

    private def footer_attributes
      [endlist_tag].compact
    end

    private macro default_params(m)
      ({{m.id}}.nil? ? defaults[{{m}}]? : {{m.id}}).not_nil!
    end

    private def defaults
      {
        sequence:             0,
        target:               10,
        iframes_only:         false,
        independent_segments: false,
        live:                 false,
        items:                [] of Items,
      }
    end

    private def playlist_size
      items.count { |item| item.is_a?(PlaylistItem) }
    end

    private def segment_size
      items.count { |item| item.is_a?(SegmentItem) }
    end

    private def master_header_attributes
      [
        m3u_tag,
        version_tag,
        independent_segments_tag,
      ].compact
    end

    private def media_header_attributes
      [
        m3u_tag,
        playlist_type_tag,
        version_tag,
        independent_segments_tag,
        iframes_only_tag,
        media_sequence,
        discontinuity_sequence_tag,
        cache_tag,
        target_duration_format,
      ].compact
    end

    private def m3u_tag
      "#EXTM3U"
    end

    private def playlist_type_tag
      "#EXT-X-PLAYLIST-TYPE:#{type}" unless type.nil?
    end

    private def version_tag
      "#EXT-X-VERSION:#{version}" unless version.nil?
    end

    private def independent_segments_tag
      "#EXT-X-INDEPENDENT-SEGMENTS" if independent_segments
    end

    private def iframes_only_tag
      "#EXT-X-I-FRAMES-ONLY" if iframes_only
    end

    private def media_sequence
      "#EXT-X-MEDIA-SEQUENCE:#{sequence}"
    end

    private def discontinuity_sequence_tag
      "#EXT-X-DISCONTINUITY-SEQUENCE:#{discontinuity_sequence}" unless discontinuity_sequence.nil?
    end

    private def cache_tag
      "#EXT-X-ALLOW-CACHE:#{parse_yes_no(cache)}" unless cache.nil?
    end

    private def target_duration_format
      "#EXT-X-TARGETDURATION:%d" % target
    end

    private def endlist_tag
      "#EXT-X-ENDLIST" unless live? || master?
    end
  end
end
