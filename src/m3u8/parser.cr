module M3U8
  # The `Parser` class is responsible for processing an M3U8 (playlist) string,
  # converting it into a structured `Playlist` object.
  class Parser
    include Concern

    # `Scanner` instance to iterate through the input string.
    getter reader : Scanner

    # The resulting `Playlist` after parsing.
    getter playlist : Playlist

    # Flag indicating whether the input has been parsed.
    getter is_parse : Bool

    # Indicates if the playlist is a live stream.
    getter live : Bool?

    # Temporary holder for the current item being built.
    @item : Items?

    # Constract a `Parser` instance. Override the default new method to allow for a no-argument instantiation.
    #
    # Usage Example:
    #
    # ```crystal
    # m3u8_string = "#EXTM3U...."
    # parser = Parser.new
    # parser.read(m3u8_string)
    # ```
    def self.new
      new("")
    end

    # Initializes the `Parser` with the given M3U8 string.
    #
    # Usage Example:
    #
    # ```crystal
    # m3u8_string = "#EXTM3U...."
    # parser = Parser.new(m3u8_string)
    # parser.read
    # ```
    def initialize(string : String)
      @reader = Scanner.new string
      @playlist = Playlist.new
      @is_parse = false
      @live = nil
      @item = nil
    end

    # A convenience class method to create a parser and parse the input in one call.
    #
    # Usage Example:
    #
    # ```crystal
    # m3u8_string = "#EXTM3U...."
    # parser = Parser.new
    # parser.read(m3u8_string)
    # ```
    def self.read(string : String)
      new(string).read
    end

    # Overloaded instance method to allow re-parsing with a provided string.
    #
    # Usage Example:
    #
    # ```crystal
    # m3u8_string = "#EXTM3U...."
    # Parser.read(m3u8_string)
    # ```
    def read(string : String)
      Parser.read(string)
    end

    # Main method that processes the input, line by line. Returns the fully parsed `Playlist`.
    #
    # Usage Example:
    #
    # ```crystal
    # # spec/playlists/live_media_playlist.m3u8
    # m3u8_string = "
    # #EXTM3U
    # #EXT-X-VERSION:3
    # #EXT-X-TARGETDURATION:8
    # #EXT-X-MEDIA-SEQUENCE:2680
    #
    # #EXTINF:7.975,
    # https://priv.example.com/fileSequence2680.ts
    # #EXTINF:7.941,
    # https://priv.example.com/fileSequence2681.ts
    # #EXTINF:7.975,
    # https://priv.example.com/fileSequence2682.ts
    # "
    #
    # parser = Parser.new(m3u8_string)
    # # => #<M3U8::Parser:0x7f0d038dbd40
    # #     @is_parse=false,
    # #     @item=nil,
    # #     @live=nil,
    # #     @playlist=
    # #      #<M3U8::Playlist:0x7f0d04a925b0
    # #       @cache=nil,
    # #       @discontinuity_sequence=nil,
    # #       @iframes_only=false,
    # #       @independent_segments=false,
    # #       @items=[],
    # #       @live=false,
    # #       @master=nil,
    # #       @sequence=0,
    # #       @target=10.0,
    # #       @type=nil,
    # #       @version=nil>,
    # #     @reader=
    # #      #<M3U8::Scanner:0x7f0d038d9450
    # #       @index=0,
    # #       @max_index=10,
    # #       @peek_index=0,
    # #       @reader=
    # #        ["#EXTM3U",
    # #         "#EXT-X-VERSION:3",
    # #         "#EXT-X-TARGETDURATION:8",
    # #         "#EXT-X-MEDIA-SEQUENCE:2680",
    # #         "",
    # #         "#EXTINF:7.975,",
    # #         "https://priv.example.com/fileSequence2680.ts",
    # #         "#EXTINF:7.941,",
    # #         "https://priv.example.com/fileSequence2681.ts",
    # #         "#EXTINF:7.975,",
    # #         "https://priv.example.com/fileSequence2682.ts"],
    # #       @size=11>>
    #
    # parser.read
    # => #<M3U8::Playlist:0x7f0d04a925b0
    # #   @cache=nil,
    # #   @discontinuity_sequence=nil,
    # #   @iframes_only=false,
    # #   @independent_segments=false,
    # #   @items=
    # #    [#<M3U8::SegmentItem:0x7f0d038dbbc0
    # #      @byterange=#<M3U8::ByteRange:0x7f0d04a60900 @length=nil, @start=nil>,
    # #      @comment="",
    # #      @duration=7.975,
    # #      @program_date_time=#<M3U8::TimeItem:0x7f0d038e1930 @time=1970-01-01 00:00:00.0 UTC>,
    # #      @segment="https://priv.example.com/fileSequence2680.ts">,
    # #     #<M3U8::SegmentItem:0x7f0d038dbb80
    # #      @byterange=#<M3U8::ByteRange:0x7f0d04a608d0 @length=nil, @start=nil>,
    # #      @comment="",
    # #      @duration=7.941,
    # #      @program_date_time=#<M3U8::TimeItem:0x7f0d038e1900 @time=1970-01-01 00:00:00.0 UTC>,
    # #      @segment="https://priv.example.com/fileSequence2681.ts">,
    # #     #<M3U8::SegmentItem:0x7f0d038dbb40
    # #      @byterange=#<M3U8::ByteRange:0x7f0d04a608a0 @length=nil, @start=nil>,
    # #      @comment="",
    # #      @duration=7.975,
    # #      @program_date_time=#<M3U8::TimeItem:0x7f0d038e18d0 @time=1970-01-01 00:00:00.0 UTC>,
    # #      @segment="https://priv.example.com/fileSequence2682.ts">],
    # #   @live=true,
    # #   @master=false,
    # #   @sequence=2680,
    # #   @target=8.0,
    # #   @type=nil,
    # #   @version=3>
    # ```
    def read
      # Avoid re-parsing if already done.
      return @playlist if @is_parse

      # Ensure the file starts with the required #EXTM3U tag.
      validate_file_format

      while !@reader.eof?
        parse @reader.current_line
        @reader.next
      end

      # If it's a media playlist (not master) and live status wasn't set, assume it's live.
      @playlist.live = true if !@playlist.master && @live.nil?

      # Mark parsing as complete.
      @is_parse = true

      @playlist
    end

    # Parses a single line of the M3U8 file.
    # Handles line continuations and dispatches based on the tag.
    private def parse(line : String)
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
        duration, comment = value.split(',')
        @item = SegmentItem.new(duration: duration.to_f, comment: comment)
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
        else
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
        @playlist.cache = parse_boolean(value)
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

    private def parse_line(line)
      case line
      when .starts_with?('#')
        # puts "comment #{@reader.lineno} #{line}"
      when .empty?
        # puts "empty #{@reader.lineno} #{line}"
      else
        parse_item line
      end
    end

    private def parse_item(line)
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
      raise Error::InvalidPlaylist.new message if @playlist.master == false
      @playlist.master = true
    end

    private def not_master!
      message = "both playlist tag and media tag. #{@reader.current_line}"
      raise Error::InvalidPlaylist.new message if @playlist.master == true
      @playlist.master = false
    end

    private def validate_file_format
      line = @reader[0]
      return if Protocol.parse(line) == :extm3u
      message = "Playlist must start with a #EXTM3U tag, line read contained the value: #{line}"
      raise Error::InvalidPlaylist.new message
    end
  end
end
