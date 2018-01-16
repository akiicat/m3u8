module M3U8
  class Parser
    alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem

    property playlist : Playlist

    @live : Bool?
    @open : Bool?
    @item : Items?

    def initialize(string : String)
      @reader = Scanner.new string
      @lineno = 0

      @playlist = M3U8::Playlist.new
      @live = nil
      @open = nil
      @item = nil
      @extm3u = true
    end

    def self.read(string : String)
      new(string).read
    end

    def read
      @reader.each do |line|
        parse line
      end
      push_item

      @playlist.live = true if !@playlist.master && @live.nil?

      raise "missing #EXTM3U tag" if @extm3u

      @playlist
    end

    def parse(line)
      tag, del, value = line.partition(':')
      # Basic Tags
      case tag
      when EXTM3U
        @extm3u = false
      when EXT_X_VERSION
        @playlist.version = value.to_i

      # media segment tags
      when EXTINF
        push_item

        item = SegmentItem.new

        duration, comment = value.split(',')
        item.duration = duration.to_f
        item.comment = comment

        @playlist.master = false
        @open = true
        @item = item

      when EXT_X_BYTERANGE
        item = @item
        item.byterange = value if item.is_a?(SegmentItem)
        @item = item

      when EXT_X_DISCONTINUITY

      when EXT_X_KEY

      when EXT_X_MAP

      when EXT_X_PROGRAM_DATE_TIME
        item = @item
        item.program_date_time = value if item.is_a?(SegmentItem)
        @item = item

      when EXT_X_DATERANGE

      # Media Playlist Tags
      when EXT_X_TARGETDURATION

      when EXT_X_MEDIA_SEQUENCE
        @playlist.sequence = value.to_i

      when EXT_X_DISCONTINUITY_SEQUENCE
        @playlist.discontinuity_sequence = value.to_i

        # EXT-X-DISCONTINUITY-SEQUENCE:8

      when EXT_X_ENDLIST
        @live = false

      when EXT_X_PLAYLIST_TYPE
        @playlist.type = value

      when EXT_X_I_FRAMES_ONLY
        @playlist.iframes_only = true

      when EXT_X_ALLOW_CACHE

      # Master Playlist Tags
      when EXT_X_MEDIA
        @playlist.master = true

      when EXT_X_STREAM_INF


      when EXT_X_I_FRAME_STREAM_INF

      when EXT_X_SESSION_DATA

      when EXT_X_SESSION_KEY

      # Media or Master Playlist Tags
      when EXT_X_INDEPENDENT_SEGMENTS

      when EXT_X_START

      when '#'
        pp line
        # comment
        # pass
      else
        parse_item line
      end
    end

    def parse_item(line)
      item = @item
      case item
      when SegmentItem
        item.segment = line
      else
        puts "can't cache this line: #{line}"
      end
      @item = item
    end

    private def push_item
      item = @item
      @playlist.items << item if item
      @item = nil
    end
  end
end
