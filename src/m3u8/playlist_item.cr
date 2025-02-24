module M3U8
  # `PlaylistItem` represents a set of attributes for either the `EXT-X-STREAM-INF` or
  # `EXT-X-I-FRAME-STREAM-INF` tag in an HLS playlist.
  #
  # In HLS, as specified in [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216):
  #   - The `EXT-X-STREAM-INF` tag ([RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2)) defines a Variant Stream and its
  #     associated attributes (e.g., PROGRAM-ID, RESOLUTION, CODECS, BANDWIDTH, etc.).
  #   - The `EXT-X-I-FRAME-STREAM-INF` tag (`iframe` is true) (also described in [RFC 8216, Section 4.3.4.3](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.3)) is used for
  #     streams that contain only I-frames, useful for trick play (fast forward, reverse, etc.).
  #
  # This class encapsulates the following properties:
  # - `program_id`:         The program identifier from the tag.
  # - `width`, `height`:    The resolution of the video (extracted from RESOLUTION).
  # - `bandwidth`:          The peak segment bit rate.
  # - `average_bandwidth`:  The average segment bit rate.
  # - `frame_rate`:         The maximum frame rate of the video.
  # - `video`:              The group identifier (`MediaItem#group_id`) for video renditions.
  # - `audio`:              The group identifier (`MediaItem#group_id`) for audio renditions.
  # - `uri`:                The URI pointing to the Media Playlist for this variant.
  # - `subtitles`:          The group identifier (`MediaItem#group_id`) for subtitles.
  # - `closed_captions`:    The closed captions setting (either a value or "NONE").
  # - `iframe`:             A boolean flag indicating whether this is an I-frame stream.
  # - `name`:               A human-readable name for the variant.
  # - `hdcp_level`:         The HDCP level requirement.
  # - `codecs`:             A `Codecs` object representing the codec information.
  #
  # Examples:
  #
  # Creating a `PlaylistItem` using a NamedTuple:
  #
  # ```crystal
  # options = {
  #   program_id:        1,
  #   width:             1920,
  #   height:            1080,
  #   bandwidth:         540,
  #   video:             "test_video",
  #   audio:             "test_a",
  #   uri:               "test.url",
  #   average_bandwidth: 500,
  #   subtitles:         "subs",
  #   closed_captions:   "cc",
  #   iframe:            true,
  #   frame_rate:        24.6,
  #   name:              "test_name",
  #   hdcp_level:        "TYPE-0",
  #   codecs:            "avc",
  #   audio_codec:       "mp3",
  #   level:             "2",
  #   profile:           "baseline",
  # }
  # item = PlaylistItem.new(options)
  # # => #<M3U8::PlaylistItem:0x78ae1a50dc00
  # #     @audio="test_a",
  # #     @average_bandwidth=500,
  # #     @bandwidth=540,
  # #     @closed_captions="cc",
  # #     @codecs=#<M3U8::Codecs:0x78ae1a4bc440 @audio_codec="mp3", @codecs="avc", @level=2.0, @profile="baseline">,
  # #     @frame_rate=24.6,
  # #     @hdcp_level="TYPE-0",
  # #     @height=1080,
  # #     @iframe=true,
  # #     @name="test_name",
  # #     @program_id=1,
  # #     @subtitles="subs",
  # #     @uri="test.url",
  # #     @video="test_video",
  # #     @width=1920>
  #
  # item.to_s
  # # => "#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS=\"avc\",BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO=\"test_a\",VIDEO=\"test_video\",SUBTITLES=\"subs\",CLOSED-CAPTIONS=\"cc\",NAME=\"test_name\",URI=\"test.url\""
  # ```
  #
  # Parsing a text string representing a stream info tag:
  #
  # ```crystal
  # text = %(#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS="avc",BANDWIDTH=540,
  #          AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO="test_a",
  #          VIDEO="test_video",SUBTITLES="subs",CLOSED-CAPTIONS="cc",NAME="test_name",URI="test.url")
  # PlaylistItem.parse(text)
  # # => #<M3U8::PlaylistItem:0x78539d754b40
  # #     @audio="test_a",
  # #     @average_bandwidth=500,
  # #     @bandwidth=540,
  # #     @closed_captions="cc",
  # #     @codecs=#<M3U8::Codecs:0x78539d7032c0 @audio_codec=nil, @codecs="avc", @level=nil, @profile=nil>,
  # #     @frame_rate=24.6,
  # #     @hdcp_level="TYPE-0",
  # #     @height=1080,
  # #     @iframe=false,
  # #     @name="test_name",
  # #     @program_id=1,
  # #     @subtitles="subs",
  # #     @uri="test.url",
  # #     @video="test_video",
  # #     @width=1920>
  # ```
  class PlaylistItem
    include Concern

    # The PROGRAM-ID attribute of the `EXT-X-STREAM-INF` and the `EXT-X-I-FRAME-STREAM-INF` tags was removed in protocol version 6.
    property program_id : Int32?

    # According to [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # the RESOLUTION attribute specifies the optimal pixel resolution at which to display all
    # the video in a Variant Stream for an `EXT-X-STREAM-INF` or `EXT-X-I-FRAME-STREAM-INF` tag.
    #
    # The attribute value is expressed as a decimal-resolution (e.g., "1920x1080"). Although it
    # is optional, including the RESOLUTION attribute is recommended when the Variant Stream contains video.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following RESOLUTION attributes:
    #
    # ```txt
    # RESOLUTION
    #
    # The value is a decimal-resolution describing the optimal pixel
    # resolution at which to display all the video in the Variant
    # Stream.
    #
    # The RESOLUTION attribute is OPTIONAL but is recommended if the
    # Variant Stream includes video.
    # ```
    #
    # These properties represent the width and height components of that resolution.
    property width : Int32?

    # According to [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # the RESOLUTION attribute specifies the optimal pixel resolution at which to display all
    # the video in a Variant Stream for an `EXT-X-STREAM-INF` or `EXT-X-I-FRAME-STREAM-INF` tag.
    #
    # The attribute value is expressed as a decimal-resolution (e.g., "1920x1080"). Although it
    # is optional, including the RESOLUTION attribute is recommended when the Variant Stream contains video.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following RESOLUTION attributes:
    #
    # ```txt
    # RESOLUTION
    #
    # The value is a decimal-resolution describing the optimal pixel
    # resolution at which to display all the video in the Variant
    # Stream.
    #
    # The RESOLUTION attribute is OPTIONAL but is recommended if the
    # Variant Stream includes video.
    # ```
    #
    # These properties represent the width and height components of that resolution.
    property height : Int32?

    # According to [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # the BANDWIDTH attribute in an
    # `EXT-X-STREAM-INF` or `EXT-X-I-FRAME-STREAM-INF` tag is a decimal integer (in bits per second)
    # that represents the peak segment bit rate of the Variant Stream.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following BANDWIDTH attributes:
    #
    # ```txt
    # BANDWIDTH
    #
    # The value is a decimal-integer of bits per second.  It represents
    # the peak segment bit rate of the Variant Stream.
    #
    # If all the Media Segments in a Variant Stream have already been
    # created, the BANDWIDTH value MUST be the largest sum of peak
    # segment bit rates that is produced by any playable combination of
    # Renditions.  (For a Variant Stream with a single Media Playlist,
    # this is just the peak segment bit rate of that Media Playlist.)
    # An inaccurate value can cause playback stalls or prevent clients
    # from playing the variant.
    #
    # If the Master Playlist is to be made available before all Media
    # Segments in the presentation have been encoded, the BANDWIDTH
    # value SHOULD be the BANDWIDTH value of a representative period of
    # similar content, encoded using the same settings.
    #
    # Every EXT-X-STREAM-INF tag MUST include the BANDWIDTH attribute.
    # ```
    property bandwidth : Int32?

    # The VIDEO attribute, as specified in [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # is defined as a quoted-string that must match the GROUP-ID attribute (`MediaItem#group_id`) of an `EXT-X-MEDIA` tag with TYPE set to VIDEO
    # in the Master Playlist. This attribute designates the set of video renditions to be used for playback.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following VIDEO attributes:
    #
    # ```txt
    # VIDEO
    #
    # The value is a quoted-string.  It MUST match the value of the
    # GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Master
    # Playlist whose TYPE attribute is VIDEO.  It indicates the set of
    # video Renditions that SHOULD be used when playing the
    # presentation.  See Section 4.3.4.2.1.
    #
    # The VIDEO attribute is OPTIONAL.
    # ```
    property video : String?

    # The AUDIO attribute, as defined in [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # is a quoted-string that must match the GROUP-ID attribute (`MediaItem#group_id`) of an `EXT-X-MEDIA` tag (with TYPE set to AUDIO) in the
    # Master Playlist. This attribute indicates the set of audio renditions that should be used for
    # playback of the presentation.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following AUDIO attributes:
    #
    # ```txt
    # AUDIO
    #
    # The value is a quoted-string.  It MUST match the value of the
    # GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Master
    # Playlist whose TYPE attribute is AUDIO.  It indicates the set of
    # audio Renditions that SHOULD be used when playing the
    # presentation.  See Section 4.3.4.2.1.
    #
    # The AUDIO attribute is OPTIONAL.
    # ```
    property audio : String?

    # As defined in [RFC 8216, Section 4.3.4.3](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.3),
    # the URI attribute for `EXT-X-I-FRAME-STREAM-INF` tags is a quoted-string containing a URI
    # that identifies the I-frame Media Playlist file. This playlist file MUST include an
    # `EXT-X-I-FRAMES-ONLY` tag.
    #
    # [RFC 8216, Section 4.3.4.3](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.3) defines the following URI attributes:
    #
    # ```txt
    # URI
    #
    # The value is a quoted-string containing a URI that identifies the
    # I-frame Media Playlist file.  That Playlist file MUST contain an
    # EXT-X-I-FRAMES-ONLY tag.
    # ```
    property uri : String?

    # The AVERAGE-BANDWIDTH attribute represents the average segment bit rate of the Variant Stream,
    # expressed as a decimal integer in bits per second.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following AVERAGE-BANDWIDTH attributes:
    #
    # ```txt
    # AVERAGE-BANDWIDTH
    #
    # The value is a decimal-integer of bits per second.  It represents
    # the average segment bit rate of the Variant Stream.
    #
    # If all the Media Segments in a Variant Stream have already been
    # created, the AVERAGE-BANDWIDTH value MUST be the largest sum of
    # average segment bit rates that is produced by any playable
    # combination of Renditions.  (For a Variant Stream with a single
    # Media Playlist, this is just the average segment bit rate of that
    # Media Playlist.)  An inaccurate value can cause playback stalls or
    # prevent clients from playing the variant.
    #
    # If the Master Playlist is to be made available before all Media
    # Segments in the presentation have been encoded, the AVERAGE-
    # BANDWIDTH value SHOULD be the AVERAGE-BANDWIDTH value of a
    # representative period of similar content, encoded using the same
    # settings.
    #
    # The AVERAGE-BANDWIDTH attribute is OPTIONAL.
    # ```
    property average_bandwidth : Int32?

    # The SUBTITLES attribute, as defined in [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # is a quoted-string that must match the GROUP-ID attribute (`MediaItem#group_id`) of an `EXT-X-MEDIA` tag (with TYPE set to SUBTITLES)
    # in the Master Playlist. It indicates the set of subtitle renditions available for playback.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following SUBTITLES attributes:
    #
    # ```txt
    # SUBTITLES
    #
    # The value is a quoted-string.  It MUST match the value of the
    # GROUP-ID attribute of an EXT-X-MEDIA tag elsewhere in the Master
    # Playlist whose TYPE attribute is SUBTITLES.  It indicates the set
    # of subtitle Renditions that can be used when playing the
    # presentation.  See Section 4.3.4.2.1.
    #
    # The SUBTITLES attribute is OPTIONAL.
    # ```
    property subtitles : String?

    # The CLOSED-CAPTIONS attribute, as defined in [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # indicates the availability of closed captioning for a Variant Stream in an HLS Master Playlist.
    #
    # This attribute can be provided in one of two forms:
    #
    #   - As a quoted-string: In this case, it must exactly match the GROUP-ID attribute (`MediaItem#group_id`) of an `EXT-X-MEDIA` tag
    #     (with TYPE CLOSED-CAPTIONS) in the playlist, indicating which closed-caption renditions
    #     are available for playback.
    #
    #   - As the enumerated-string value NONE: This signifies that no closed captions are present in any
    #     Variant Stream. In such cases, every `EXT-X-STREAM-INF` tag MUST include "CLOSED-CAPTIONS=NONE".
    #
    # Consistency is essential; mixing closed captions across Variant Streams may cause playback errors.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following CLOSED-CAPTIONS attributes:
    #
    # ```txt
    # CLOSED-CAPTIONS
    #
    # The value can be either a quoted-string or an enumerated-string
    # with the value NONE.  If the value is a quoted-string, it MUST
    # match the value of the GROUP-ID attribute of an EXT-X-MEDIA tag
    # elsewhere in the Playlist whose TYPE attribute is CLOSED-CAPTIONS,
    # and it indicates the set of closed-caption Renditions that can be
    # used when playing the presentation.  See Section 4.3.4.2.1.
    #
    # If the value is the enumerated-string value NONE, all EXT-X-
    # STREAM-INF tags MUST have this attribute with a value of NONE,
    # indicating that there are no closed captions in any Variant Stream
    # in the Master Playlist.  Having closed captions in one Variant
    # Stream but not another can trigger playback inconsistencies.
    #
    # The CLOSED-CAPTIONS attribute is OPTIONAL.
    # ```
    property closed_captions : String?

    # Indicates whether the playlist should use an I-frame only stream tag.
    # When `iframe` is true, the `EXT-X-I-FRAME-STREAM-INF` tag will be output, which is
    # typically used for trick play (e.g., fast forward, reverse) as it contains only I-frames.
    # If `iframe` is false, the standard `EXT-X-STREAM-INF` tag is used.
    property iframe : Bool

    # According to [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # the FRAME-RATE attribute specifies the maximum frame rate (in frames per second) for all video
    # in the Variant Stream. This value is expressed as a decimal floating-point number, rounded to
    # three decimal places.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following FRAME-RATE attributes:
    #
    # ```txt
    # FRAME-RATE
    #
    # The value is a decimal-floating-point describing the maximum frame
    # rate for all the video in the Variant Stream, rounded to three
    # decimal places.
    #
    # The FRAME-RATE attribute is OPTIONAL but is recommended if the
    # Variant Stream includes video.  The FRAME-RATE attribute SHOULD be
    # included if any video in a Variant Stream exceeds 30 frames per
    # second.
    # ```
    property frame_rate : Float64?

    # DEPRECATED: Use in `EXT-X-MEDIA` tag, not in `EXT-X-STREAM-INF`
    property name : String?

    # According to [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # the HDCP-LEVEL attribute is defined as an enumerated-string indicating the required level
    # of High-bandwidth Digital Content Protection (HDCP) for a Variant Stream.
    #
    # Valid values are:
    #   - `TYPE-0`: Signifies that the Variant Stream may fail to play unless the output is
    #     protected by HDCP Type 0 (or an equivalent mechanism).
    #   - `NONE`:   Indicates that the content does not require any output copy protection.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following HDCP-LEVEL attributes:
    #
    # ```txt
    # HDCP-LEVEL
    #
    # The value is an enumerated-string; valid strings are TYPE-0 and
    # NONE.  This attribute is advisory; a value of TYPE-0 indicates
    # that the Variant Stream could fail to play unless the output is
    # protected by High-bandwidth Digital Content Protection (HDCP) Type
    # 0 [HDCP] or equivalent.  A value of NONE indicates that the
    # content does not require output copy protection.
    #
    # Encrypted Variant Streams with different HDCP levels SHOULD use
    # different media encryption keys.
    #
    # The HDCP-LEVEL attribute is OPTIONAL.  It SHOULD be present if any
    # content in the Variant Stream will fail to play without HDCP.
    # Clients without output copy protection SHOULD NOT load a Variant
    # Stream with an HDCP-LEVEL attribute unless its value is NONE.
    # ```
    property hdcp_level : String?

    # This property holds a `Codecs` instance that encapsulates the *CODECS* attribute
    # for a Variant Stream in an HLS playlist.
    #
    # According to [RFC 8216, Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2),
    # the CODECS attribute is a quoted string that contains a comma-separated list of format identifiers.
    # Each identifier specifies a media sample type present in one or more renditions of the Variant Stream.
    #
    # [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) defines the following CODECS attributes:
    #
    # ```txt
    # CODECS
    #
    # The value is a quoted-string containing a comma-separated list of
    # formats, where each format specifies a media sample type that is
    # present in one or more Renditions specified by the Variant Stream.
    # Valid format identifiers are those in the ISO Base Media File
    # Format Name Space defined by "The 'Codecs' and 'Profiles'
    # Parameters for "Bucket" Media Types" [RFC6381].
    #
    # For example, a stream containing AAC low complexity (AAC-LC) audio
    # and H.264 Main Profile Level 3.0 video would have a CODECS value
    # of "mp4a.40.2,avc1.4d401e".
    #
    # Every EXT-X-STREAM-INF tag SHOULD include a CODECS attribute.
    # ```
    property codecs : Codecs

    # Parses a text string representing an `EXT-X-STREAM-INF` or `EXT-X-I-FRAME-STREAM-INF` tag.
    #
    # Example:
    #
    # ```crystal
    # text = %(#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080, \
    #          CODECS="avc",BANDWIDTH=540,AVERAGE-BANDWIDTH=500, \
    #          FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO="test_a", \
    #          VIDEO="test_video",SUBTITLES="subs",CLOSED-CAPTIONS="cc", \
    #          URI="test.url")
    # PlaylistItem.parse(text)
    # # => #<M3U8::PlaylistItem:0x7bf1a06aca80
    # #     @audio="test_a",
    # #     @average_bandwidth=500,
    # #     @bandwidth=540,
    # #     @closed_captions="cc",
    # #     @codecs=#<M3U8::Codecs:0x7bf1a065b180 @audio_codec=nil, @codecs="avc", @level=nil, @profile=nil>,
    # #     @frame_rate=24.6,
    # #     @hdcp_level="TYPE-0",
    # #     @height=1080,
    # #     @iframe=false,
    # #     @program_id=1,
    # #     @subtitles="subs",
    # #     @uri="test.url",
    # #     @video="test_video",
    # #     @width=1920>
    # ```
    def self.parse(value)
      attributes = parse_attributes(value)
      resolution = parse_resolution(attributes["RESOLUTION"]?)
      new(
        program_id: attributes["PROGRAM-ID"]?,
        codecs: attributes["CODECS"]?,
        width: resolution[:width]?,
        height: resolution[:height]?,
        bandwidth: attributes["BANDWIDTH"]?.try &.to_i,
        average_bandwidth: attributes["AVERAGE-BANDWIDTH"]?.try &.to_i,
        iframe: value.includes?("#EXT-X-I-FRAME-STREAM-INF:"),
        frame_rate: parse_frame_rate(attributes["FRAME-RATE"]?),
        video: attributes["VIDEO"]?,
        audio: attributes["AUDIO"]?,
        uri: attributes["URI"]?,
        subtitles: attributes["SUBTITLES"]?,
        closed_captions: attributes["CLOSED-CAPTIONS"]?,
        name: attributes["NAME"]?,
        hdcp_level: attributes["HDCP-LEVEL"]?
      )
    end

    # Constructs a new `PlaylistItem` instance from a NamedTuple.
    #
    # The NamedTuple should contain keys corresponding to the tag attributes, such as:
    #   `program_id`, `width`, `height`, `bandwidth`, `video`, `audio`, `uri`,
    #   `average_bandwidth`, `subtitles`, `closed_captions`, `iframe`, `frame_rate`,
    #   `hdcp_level`, `codecs`, along with codec-related keys (`Codecs#audio_codec`, `Codecs#level`, `Codecs#profile`).
    #
    # Example:
    #
    # ```crystal
    # options = {
    #   program_id:        1,
    #   width:             1920,
    #   height:            1080,
    #   bandwidth:         540,
    #   video:             "test_video",
    #   audio:             "test_a",
    #   uri:               "test.url",
    #   average_bandwidth: 500,
    #   subtitles:         "subs",
    #   closed_captions:   "cc",
    #   iframe:            true,
    #   frame_rate:        24.6,
    #   hdcp_level:        "TYPE-0",
    #   codecs:            "avc",
    #   audio_codec:       "mp3",
    #   level:             "2",
    #   profile:           "baseline",
    # }
    # PlaylistItem.new(options)
    # # => #<M3U8::PlaylistItem:0x7e7089b309c0
    # #     @audio="test_a",
    # #     @average_bandwidth=500,
    # #     @bandwidth=540,
    # #     @closed_captions="cc",
    # #     @codecs=#<M3U8::Codecs:0x7e7089adf080 @audio_codec="mp3", @codecs="avc", @level=2.0, @profile="baseline">,
    # #     @frame_rate=24.6,
    # #     @hdcp_level="TYPE-0",
    # #     @height=1080,
    # #     @iframe=true,
    # #     @program_id=1,
    # #     @subtitles="subs",
    # #     @uri="test.url",
    # #     @video="test_video",
    # #     @width=1920>
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        program_id: params[:program_id]?,
        width: params[:width]?,
        height: params[:height]?,
        bandwidth: params[:bandwidth]?,
        video: params[:video]?,
        audio: params[:audio]?,
        uri: params[:uri]?,
        average_bandwidth: params[:average_bandwidth]?,
        subtitles: params[:subtitles]?,
        closed_captions: params[:closed_captions]?,
        iframe: params[:iframe]?,
        frame_rate: params[:frame_rate]?,
        name: params[:name]?,
        hdcp_level: params[:hdcp_level]?,
        codecs: params[:codecs]?,
        audio_codec: params[:audio_codec]?,
        level: params[:level]?,
        profile: params[:profile]?,
      )
    end

    # Initializes a new `PlaylistItem` instance.
    #
    # The initializer accepts individual parameters for each attribute.
    #
    # Example:
    #
    # ```crystal
    # PlaylistItem.new(program_id: 1,
    #                  width: 1920,
    #                  height: 1080,
    #                  bandwidth: 540,
    #                  video:"test_video",
    #                  audio: "test_a",
    #                  uri: "test.url",
    #                  average_bandwidth: 500,
    #                  subtitles: "subs",
    #                  closed_captions: "cc",
    #                  iframe: true,
    #                  frame_rate: 24.6,
    #                  hdcp_level: "TYPE-0",
    #                  codecs: "avc",
    #                  audio_codec: "mp3",
    #                  level: "2",
    #                  profile: "baseline")
    # # => #<M3U8::PlaylistItem:0x7d7806d39900
    # #     @audio="test_a",
    # #     @average_bandwidth=500,
    # #     @bandwidth=540,
    # #     @closed_captions="cc",
    # #     @codecs=#<M3U8::Codecs:0x7d7806ce84c0 @audio_codec="mp3", @codecs="avc", @level=2.0, @profile="baseline">,
    # #     @frame_rate=24.6,
    # #     @hdcp_level="TYPE-0",
    # #     @height=1080,
    # #     @iframe=true,
    # #     @program_id=1,
    # #     @subtitles="subs",
    # #     @uri="test.url",
    # #     @video="test_video",
    # #     @width=1920>
    # ```
    def initialize(program_id = nil,
                   @width = nil,
                   @height = nil,
                   @bandwidth = nil,
                   @video = nil,
                   @audio = nil,
                   @uri = nil,
                   @average_bandwidth = nil,
                   @subtitles = nil,
                   @closed_captions = nil,
                   iframe = nil,
                   frame_rate = nil,
                   @name = nil,
                   @hdcp_level = nil,
                   codecs = nil,
                   audio_codec = nil,
                   level = nil,
                   profile = nil)
      @program_id = program_id ? program_id.to_i : nil
      @iframe = iframe ? true : false
      @frame_rate = frame_rate ? frame_rate.to_f : nil
      @codecs = Codecs.new({
        codecs:      codecs,
        audio_codec: audio_codec,
        level:       level,
        profile:     profile,
      })
    end

    # Returns the resolution in the format `<width>x<height>`.
    #
    # Example:
    # ```crystal
    # options = { width: 1920, height: 1080 }
    # item = PlaylistItem.new(options)
    # item.resolution  # => "1920x1080"
    # ```
    def resolution
      "#{width}x#{height}" unless width.nil?
    end

    # Returns the string representation of the stream info tag.
    #
    # If the `iframe` flag is true, the tag is formatted as `EXT-X-I-FRAME-STREAM-INF`;
    # otherwise, it is formatted as `EXT-X-STREAM-INF` followed by the URI on a new line.
    #
    # Example for an I-frame stream:
    #
    # ```crystal
    # options = {
    #   program_id: 1,
    #   width: 1920,
    #   height: 1080,
    #   bandwidth: 540,
    #   video: "test_video",
    #   audio: "test_a",
    #   uri: "test.url",
    #   average_bandwidth: 500,
    #   subtitles: "subs",
    #   closed_captions: "cc",
    #   iframe: true,
    #   frame_rate: 24.6,
    #   hdcp_level: "TYPE-0",
    #   codecs: "avc",
    #   audio_codec: "mp3",
    #   level: "2",
    #   profile: "baseline",
    # }
    # PlaylistItem.new(options).to_s
    # # => "#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS=\"avc\",BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO=\"test_a\",VIDEO=\"test_video\",SUBTITLES=\"subs\",CLOSED-CAPTIONS=\"cc\",URI=\"test.url\""
    # ```
    #
    # Example for a standard stream:
    #
    # ```crystal
    # options = {
    #   program_id: 1,
    #   width: 1920,
    #   height: 1080,
    #   bandwidth: 540,
    #   video: "test_video",
    #   audio: "test_a",
    #   uri: "test.url",
    #   average_bandwidth: 500,
    #   subtitles: "subs",
    #   closed_captions: "cc",
    #   iframe: false,
    #   frame_rate: 24.6,
    #   hdcp_level: "TYPE-0",
    #   codecs: "avc",
    #   audio_codec: "mp3",
    #   level: "2",
    #   profile: "baseline",
    # }
    # PlaylistItem.new(options).to_s
    # # => "#EXT-X-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS=\"avc\",BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO=\"test_a\",VIDEO=\"test_video\",SUBTITLES=\"subs\",CLOSED-CAPTIONS=\"cc\"\n" +
    # #    "test.url"
    # ```
    def to_s
      if iframe
        %(#EXT-X-I-FRAME-STREAM-INF:#{attributes.join(',')},URI="#{uri}")
      else
        %(#EXT-X-STREAM-INF:#{attributes.join(',')}\n#{uri})
      end
    end

    private def attributes
      [
        program_id_format,
        resolution_format,
        codecs_format,
        bandwidth_format,
        average_bandwidth_format,
        frame_rate_format,
        hdcp_level_format,
        audio_format,
        video_format,
        subtitles_format,
        closed_captions_format,
        name_format,
      ].compact
    end

    private def program_id_format
      %(PROGRAM-ID=#{program_id}) unless program_id.nil?
    end

    private def resolution_format
      %(RESOLUTION=#{resolution}) unless resolution.nil?
    end

    private def frame_rate_format
      %(FRAME-RATE=%.3f) % frame_rate unless frame_rate.nil?
    end

    private def hdcp_level_format
      %(HDCP-LEVEL=#{hdcp_level}) unless hdcp_level.nil?
    end

    private def codecs_format
      %(CODECS="#{codecs.to_s}") unless codecs.empty?
    end

    private def bandwidth_format
      %(BANDWIDTH=#{bandwidth}) unless bandwidth.nil?
    end

    private def average_bandwidth_format
      %(AVERAGE-BANDWIDTH=#{average_bandwidth}) unless average_bandwidth.nil?
    end

    private def audio_format
      %(AUDIO="#{audio}") unless audio.nil?
    end

    private def video_format
      %(VIDEO="#{video}") unless video.nil?
    end

    private def subtitles_format
      %(SUBTITLES="#{subtitles}") unless subtitles.nil?
    end

    private def closed_captions_format
      case closed_captions
      when "NONE" then %(CLOSED-CAPTIONS=NONE)
      when String then %(CLOSED-CAPTIONS="#{closed_captions}")
      end
    end

    private def name_format
      %(NAME="#{name}") unless name.nil?
    end
  end
end
