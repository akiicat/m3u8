module M3U8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem

    @master : Bool?

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

    def initialize(params = NamedTuple.new)
      @master = default_params(:master)

      @version = default_params(:version)
      @cache = default_params(:cache)
      @discontinuity_sequence = default_params(:discontinuity_sequence)
      @type = default_params(:type)

      @target = default_params(:target).not_nil!.to_f
      @sequence = default_params(:sequence).not_nil!
      @iframes_only = default_params(:iframes_only).not_nil!
      @independent_segments = default_params(:independent_segments).not_nil!
      @live = default_params(:live).not_nil!
      @items = default_params(:items).not_nil!
    end

    def self.codecs(options = NamedTuple.new)
      PlaylistItem.new(options).codecs
    end

    # def self.read(input)
    #   Reader.new.read(input)
    # end

    def live?
      master? ? false : @live
    end

    def master?
      return @master unless @master.nil?
      (playlist_size.zero? && segment_size.zero?) ? false : playlist_size > 0
    end

    def valid?
      (playlist_size.zero? || segment_size.zero?) ? true : false 
    end

    def valid!
      raise PlaylistTypeError.new("Playlist is invalid.") unless valid?
    end

    def duration
      items.reduce(0.0) do |acc, item| 
        item.is_a?(SegmentItem) ? acc + item.duration : acc
      end
    end

    def to_s
      attributes.join('\n') + "\n"
    end

    def attributes
      valid!

      [
        header_attributes,
        items_attributes,
        footer_attributes
      ].flatten
    end

    def header_attributes
      master? ? master_header_attributes : media_header_attributes
    end

    def items_attributes
      items.map { |item| item.to_s }
    end

    def footer_attributes
      [endlist_tag].compact
    end

    private macro default_params(m)
      params[{{m}}]? == nil ? defaults[{{m}}]? : params[{{m}}]?
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
      "#EXT-X-ALLOW-CACHE:#{cache.not_nil!.to_yes_no}" unless cache.nil?
    end

    private def target_duration_format
      "#EXT-X-TARGETDURATION:%d" % target
    end

    private def endlist_tag
      "#EXT-X-ENDLIST" unless live? || master?
    end

  end
end
