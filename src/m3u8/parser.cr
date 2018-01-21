module M3U8
  class Parser
    include Concern

    property playlist : Playlist

    @live : Bool?
    @item : Items?

    def initialize(string : String)
      @reader = Scanner.new string
      @is_parse = false

      @playlist = M3U8::Playlist.new
      @live = nil
      @item = nil
      @extm3u = true
    end

    def self.read(string : String)
      new(string).read
    end

    def read(string : String)
      Parser.read(string)
    end

    def read
      return @playlist if @is_parse

      validate_file_format

      while !@reader.eof?
        parse @reader.current_line
        @reader.next
      end

      @playlist.live = true if !@playlist.master && @live.nil?

      @is_parse = true

      @playlist
    end

    def parse(line : String)
      while line.ends_with?('\\')
        line = line.rchop.rstrip + @reader.next
      end

      tag, del, value = line.partition(':')

      if MEDIA_SEGMENT_TAGS.includes? tag
        not_master!
      end
      if MEDIA_PLAYLIST_TAGS.includes? tag
        not_master!
      end
      if MASTER_PLAYLIST_TAGS.includes? tag
        master!
      end

      # Basic Tags
      case tag
      when EXTM3U
        @extm3u = false

      when EXT_X_VERSION
        @playlist.version = value.to_i

      # media segment tags
      when EXTINF
        item = SegmentItem.new

        duration, comment = value.split(',')
        item.duration = duration.to_f
        item.comment = comment

        @item = item

      when EXT_X_BYTERANGE
        item = @item
        item.byterange = value if item.is_a?(SegmentItem)
        @item = item

      when EXT_X_DISCONTINUITY
        push_item DiscontinuityItem.new

      when EXT_X_KEY
        push_item KeyItem.parse value

      when EXT_X_MAP
        push_item MapItem.parse value

      when EXT_X_PROGRAM_DATE_TIME
        item = @item
        case item
        when SegmentItem
          item.program_date_time = value
          @item = item
        when Nil
          push_item TimeItem.new(value)
        end

      when EXT_X_DATERANGE
        next_line = @reader.next
        while !next_line.starts_with?('#')
          line += next_line
          next_line = @reader.next
        end

        push_item DateRangeItem.parse value

        parse next_line

      # Media Playlist Tags
      when EXT_X_TARGETDURATION
        @playlist.target = value.to_f

      when EXT_X_MEDIA_SEQUENCE
        @playlist.sequence = value.to_i

      when EXT_X_DISCONTINUITY_SEQUENCE
        @playlist.discontinuity_sequence = value.to_i

      when EXT_X_ENDLIST
        @live = false

      when EXT_X_PLAYLIST_TYPE
        @playlist.type = value

      when EXT_X_I_FRAMES_ONLY
        @playlist.iframes_only = true

      when EXT_X_ALLOW_CACHE
        @playlist.cache = value.to_boolean

      # Master Playlist Tags
      when EXT_X_MEDIA
        push_item MediaItem.parse value

      when EXT_X_STREAM_INF
        @item = PlaylistItem.parse value

      when EXT_X_I_FRAME_STREAM_INF
        item = PlaylistItem.parse value
        item.iframe = true
        push_item item

      when EXT_X_SESSION_DATA
        push_item SessionDataItem.parse value

      when EXT_X_SESSION_KEY
        push_item SessionKeyItem.parse value

      # Media or Master Playlist Tags
      when EXT_X_INDEPENDENT_SEGMENTS
        @playlist.independent_segments = true

      when EXT_X_START
        push_item PlaybackStart.parse value

      when .starts_with?('#'), .empty?
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
        push_item
      when PlaylistItem
        item.uri = line
        push_item
      else
        puts "BUG: Can't parse this line #{@reader.lineno} #{line}"
      end
    end

    private def push_item(item = @item)
      @playlist.items << item if item
      @item = nil
    end

    private def master!
      message = "both playlist tag and media tag. #{@reader.current_line}"
      raise InvalidPlaylistError.new message if @playlist.master == false
      @playlist.master = true
    end

    private def not_master!
      message = "both playlist tag and media tag. #{@reader.current_line}"
      raise InvalidPlaylistError.new message if @playlist.master == true
      @playlist.master = false
    end

    private def validate_file_format
      line = @reader[0]
      return if line == EXTM3U
      message = "Playlist must start with a #EXTM3U tag, line read contained the value: #{line}"
      raise InvalidPlaylistError.new message
    end
  end
end
