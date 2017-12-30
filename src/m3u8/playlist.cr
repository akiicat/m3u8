module M3U8
  # Playlist represents an m3u8 playlist, it can be a master playlist or a set
  # of media segments
  class Playlist
    alias Items = SegmentItem | PlaylistItem

    @master : Bool?

    property version : Int32?
    property cache : Bool?
    property discontinuity_sequence : Int32?
    property type : String?

    property target : Int32
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

      @target = default_params(:target).not_nil!
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

    # def write(output)
    #   Writer.new(output).write(self)
    # end

    def live?
      return false if master?
      @live
    end

    def master?
      return @master unless @master.nil?
      return false if playlist_size.zero? && segment_size.zero?
      playlist_size > 0
    end

    # def to_s
    #   output = StringIO.open
    #   write(output)
    #   output.string
    # end

    def valid?
      return false if playlist_size > 0 && segment_size > 0
      true
    end

    def duration
      duration = 0.0
      items.each do |item|
        duration += item.duration if item.is_a?(SegmentItem)
      end
      duration
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
  end
end
