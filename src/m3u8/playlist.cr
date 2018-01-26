module M3U8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    include Concern

    property master : Bool?

    property version : Int32?
    property cache : Bool?
    property discontinuity_sequence : Int32?
    property type : String?

    property target : Float64
    property sequence : Int32
    property iframes_only : Bool
    property independent_segments : Bool
    property live : Bool
    property items : Array(Items)

    # ```
    # options = {
    #   version: 7,
    #   cache: false,
    #   target: 12,
    #   sequence: 1,
    #   discontinuity_sequence: 2,
    #   type: "VOD",
    #   independent_segments: true
    # }
    # Playlist.new(options)
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

    # ```
    # Playlist.new
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

    # ```
    # options = {
    #   profile: "baseline",
    #   level: 3.0,
    #   audio_codec: "aac-lc"
    # }
    # Playlist.codecs(options) # => "avc1.66.30,mp4a.40.2"
    # ```
    def self.codecs(options = NamedTuple.new)
      Codecs.new(options).to_s
    end

    # ```
    # m3u8_string = "#EXTM3U....."
    # Playlist.parse(m3u8_string)
    # # => #<M3U8::Playlist......>
    # ```
    def self.parse(input)
      Parser.read(input)
    end

    # ```
    # playlist = Playlist.new(live: true)
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
    # playlist.live? # => true
    # ```
    def live?
      master? ? false : live
    end

    # ```
    # options = { master: true }
    # playlist = Playlist.new(options)
    # playlist.master? # => true
    # ```
    def master?
      return master unless master.nil?
      (playlist_size.zero? && segment_size.zero?) ? false : playlist_size > 0
    end

    # ```
    # playlist = Playlist.new
    #
    # options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url" }
    # playlist.items << PlaylistItem.new(options)
    #
    # playlist.valid? # => true
    #
    # options = { duration: 10.991, segment: "test.ts" }
    # playlist.items << SegmentItem.new(options)
    #
    # playlist.valid? # => false
    # ```
    def valid?
      (playlist_size.zero? || segment_size.zero?) ? true : false 
    end

    # ```
    # playlist = Playlist.new
    #
    # options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url" }
    # playlist.items << PlaylistItem.new(options)
    #
    # playlist.valid! # => nil
    #
    # options = { duration: 10.991, segment: "test.ts" }
    # playlist.items << SegmentItem.new(options)
    #
    # playlist.valid! # => Playlist is invalid. (M3U8::Error::PlaylistType)
    # ```
    def valid!
      raise Error::PlaylistType.new("Playlist is invalid.") unless valid?
    end

    # ```
    # playlist = Playlist.new
    #
    # playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
    # playlist.items << SegmentItem.new(duration: 9.891, segment: "test_02.ts")
    # playlist.items << SegmentItem.new(duration: 10.556, segment: "test_03.ts")
    # playlist.items << SegmentItem.new(duration: 8.790, segment: "test_04.ts")
    #
    # playlist.duration # => 40.227999999999994
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
    # options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
    # playlist.items << PlaylistItem.new(options)
    #
    # playlist.to_s
    # # => %(#EXTM3U\n) \
    #      %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34",) \
    #      %(BANDWIDTH=6400\nplaylist_url\n)
    # ```
    def to_s
      attributes.join('\n') + "\n"
    end

    # ```
    # playlist = Playlist.new(version: 6, independent_segments: true)
    # playlist.header
    # # => "#EXTM3U\n" \
    #      "#EXT-X-VERSION:6\n" \
    #      "#EXT-X-INDEPENDENT-SEGMENTS\n" \
    #      "#EXT-X-MEDIA-SEQUENCE:0\n" \
    #      "#EXT-X-TARGETDURATION:10"
    # ```
    def header
      header_attributes.join('\n')
    end

    # ```
    # playlist = Playlist.new(version: 6, independent_segments: true)
    # 
    # options = { duration: 10.991, segment: "test.ts" }
    # playlist.items << SegmentItem.new(options)
    #
    # playlist.body # => "#EXTINF:10.991,\ntest.ts"
    # ```
    def body
      body_attributes.join('\n')
    end

    # ```
    # playlist = Playlist.new(version: 6, independent_segments: true)
    # 
    # options = { duration: 10.991, segment: "test.ts" }
    # playlist.items << SegmentItem.new(options)
    #
    # playlist.footer # => "#EXT-X-ENDLIST"
    # ```
    def footer
      footer_attributes.join('\n')
    end

    private def attributes
      valid!
      [
        header_attributes,
        body_attributes,
        footer_attributes
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
        sequence: 0,
        target: 10,
        iframes_only: false,
        independent_segments: false,
        live: false,
        items: [] of Items
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
        independent_segments_tag
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
        target_duration_format
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

