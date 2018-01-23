module M3U8
  class Parser
    include Concern

    getter reader : Scanner
    getter playlist : Playlist
    getter is_parse : Bool
    getter live : Bool?
    @item : Items?

    def initialize(string : String)
      @reader = Scanner.new string
      @playlist = Playlist.new
      @is_parse = false
      @live = nil
      @item = nil
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

      tag, value = partition(line)

      not_master! if MEDIA_TAGS.includes? tag
      master! if MASTER_PLAYLIST_TAGS.includes? tag

      # Basic Tags
      case tag
      when :extm3u
      when :ext_x_version
        @playlist.version = value.to_i

      # media segment tags
      when :extinf
        item = SegmentItem.new

        duration, comment = value.split(',')
        item.duration = duration.to_f
        item.comment = comment

        @item = item

      when :ext_x_byterange
        item = @item
        item.byterange = value if item.is_a?(SegmentItem)
        @item = item

      when :ext_x_discontinuity
        push_item DiscontinuityItem.new

      when :ext_x_key
        push_item KeyItem.parse value

      when :ext_x_map
        push_item MapItem.parse value

      when :ext_x_program_date_time
        item = @item
        case item
        when SegmentItem
          item.program_date_time = value
          @item = item
        when Nil
          push_item TimeItem.new(value)
        end

      when :ext_x_daterange
        tag, value = partition full_line(line)
        push_item DateRangeItem.parse value

      # Media Playlist Tags
      when :ext_x_targetduration
        @playlist.target = value.to_f

      when :ext_x_media_sequence
        @playlist.sequence = value.to_i

      when :ext_x_discontinuity_sequence
        @playlist.discontinuity_sequence = value.to_i

      when :ext_x_endlist
        @live = false

      when :ext_x_playlist_type
        @playlist.type = value

      when :ext_x_i_frames_only
        @playlist.iframes_only = true

      when :ext_x_allow_cache
        @playlist.cache = value.to_boolean

      # Master Playlist Tags
      when :ext_x_media
        push_item MediaItem.parse value

      when :ext_x_stream_inf
        @item = PlaylistItem.parse value

      when :ext_x_i_frame_stream_inf
        item = PlaylistItem.parse value
        item.iframe = true
        push_item item

      when :ext_x_session_data
        push_item SessionDataItem.parse value

      when :ext_x_session_key
        push_item SessionKeyItem.parse value

      # Media or Master Playlist Tags
      when :ext_x_independent_segments
        @playlist.independent_segments = true

      when :ext_x_start
        push_item PlaybackStart.parse value

      # Experimental Tags
      when :ext_x_cue_out, :ext_x_cue_out_cont, :ext_x_cue_in, :ext_x_cue_span, :ext_oatcls_scte35
        puts "Not support experimental tag #{@reader.lineno} #{line}"

      else
        parse_line(line)
      end
    end

    def parse_line(line)
      case line
      when .starts_with?('#')
        # puts "comment #{@reader.lineno} #{line}"
      when .empty?
        # puts "empty #{@reader.lineno} #{line}"
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

    private def full_line(line : String)
      tag, value = partition(@reader.peek)
      while !ALL_TAGS.includes?(tag)
        str = @reader.next
        line += str if !str.starts_with?('#')
        tag, value = partition(@reader.peek)
      end
      line
    end

    private def partition(line)
      tag, del, value = line.partition(':')
      return Protocol.parse(tag), value
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
      return if Protocol.parse(line) == :extm3u
      message = "Playlist must start with a #EXTM3U tag, line read contained the value: #{line}"
      raise InvalidPlaylistError.new message
    end
  end
end
