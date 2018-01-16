module M3U8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem

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

    def self.codecs(options = NamedTuple.new)
      Codecs.new(options).to_s
    end

    # def self.read(input)
    #   Reader.new.read(input)
    # end

    def live?
      master? ? false : live
    end

    def master?
      return master unless master.nil?
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
        duration = item.duration if item.is_a?(SegmentItem)
        duration ||= 0.0
        acc + duration
      end
    end

    def to_s
      attributes.join('\n') + "\n"
    end

    def attributes
      valid!

      [
        header_attributes,
        body_attributes,
        footer_attributes
      ].flatten
    end

    def header_attributes
      master? ? master_header_attributes : media_header_attributes
    end

    def body_attributes
      items.map { |item| item.to_s }
    end

    def footer_attributes
      [endlist_tag].compact
    end

    def header
      header_attributes.join('\n')
    end

    def body
      body_attributes.join('\n')
    end

    def footer
      footer_attributes.join('\n')
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
