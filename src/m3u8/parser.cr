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
      tag, del, value = line.partition(':')

      if BASIC_TAGS.includes? tag
      end
      if MEDIA_SEGMENT_TAGS.includes? tag
        not_master!
      end
      if MEDIA_PLAYLIST_TAGS.includes? tag
        not_master!
      end
      if MASTER_PLAYLIST_TAGS.includes? tag
        master!
      end
      if MASTER_MEDIA_PLAYLIST_TAGS.includes? tag
      end
      if EXPERIMENTAL_TAGS.includes? tag
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
        options = parse_map_item_attributes(value)
        push_item MapItem.new options

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

        options = parse_data_range_item_attrubtes(value)
        push_item DateRangeItem.new options

        parse next_line

      # Media Playlist Tags
      when EXT_X_TARGETDURATION
        @playlist.target = value.to_f


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
        @playlist.cache = value.to_boolean


      # Master Playlist Tags
      when EXT_X_MEDIA
        options = parse_media_attributes(value)
        push_item MediaItem.new options

      when EXT_X_STREAM_INF
        options = parse_playlist_attributes(value)
        @item = PlaylistItem.new options

      when EXT_X_I_FRAME_STREAM_INF
        options = parse_playlist_attributes(value).merge({ iframe: true })
        push_item PlaylistItem.new options

      when EXT_X_SESSION_DATA
        options = parse_session_data_attributes(value)
        push_item SessionDataItem.new options

      when EXT_X_SESSION_KEY
        push_item SessionKeyItem.parse value

      # Media or Master Playlist Tags
      when EXT_X_INDEPENDENT_SEGMENTS
        @playlist.independent_segments = true

      when EXT_X_START
        options = parse_playback_start_attributes(value)
        push_item PlaybackStart.new options

      when .starts_with?('#')
        puts "skip comment:#{@reader.lineno} #{line}"
        # comment
        # pass
      when .empty?
        puts "skip empty line:#{@reader.lineno} #{line}"
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
        puts "can't cache this line: #{line}"
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

    def validate_file_format
      line = @reader[0]
      return if line == EXTM3U
      message = "Playlist must start with a #EXTM3U tag, line read " \
                "contained the value: #{line}"
      raise InvalidPlaylistError.new message
    end

    def parse_attributes(line)
      array = line.scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.map { |reg| [reg[1], reg[2].delete('"')] }.to_h
    end

    def parse_map_item_attributes(text)
      attributes = parse_attributes(text)

      {
        uri: attributes["URI"],
        byterange: parse_byterange(attributes["BYTERANGE"]?),
      }
    end


    def parse_data_range_item_attrubtes(text)
      attributes = parse_attributes(text)
      {
        id: attributes["ID"]?,
        class_name: attributes["CLASS"]?,
        start_date: attributes["START-DATE"]?,
        end_date: attributes["END-DATE"]?,
        duration: attributes["DURATION"]?.try &.to_f,
        planned_duration: attributes["PLANNED-DURATION"]?.try &.to_f,
        scte35_cmd: attributes["SCTE35-CMD"]?,
        scte35_out: attributes["SCTE35-OUT"]?,
        scte35_in: attributes["SCTE35-IN"]?,
        end_on_next: attributes.key?("END-ON-NEXT") ? true : false,
        client_attributes: parse_client_attributes(attributes),
      }
    end

    # dup
    private alias ClientAttributeType = Hash(String | Symbol, String | Int32 | Float64 | Bool | Nil)
    private def parse_client_attributes(attributes)
      hash = ClientAttributeType.new
      if attributes
        hash.merge!(attributes.select { |key| key.starts_with?("X-") if key.is_a?(String) })
      end
      hash
    end

    def parse_media_attributes(text)
      attributes = parse_attributes(text)
      {
        type: attributes["TYPE"]?,
        group_id: attributes["GROUP-ID"]?,
        language: attributes["LANGUAGE"]?,
        assoc_language: attributes["ASSOC-LANGUAGE"]?,
        name: attributes["NAME"]?,
        autoselect: attributes["AUTOSELECT"]?.try &.to_boolean,
        default: attributes["DEFAULT"]?.try &.to_boolean,
        forced: attributes["FORCED"]?.try &.to_boolean,
        uri: attributes["URI"]?,
        instream_id: attributes["INSTREAM-ID"]?,
        characteristics: attributes["CHARACTERISTICS"]?,
        channels: attributes["CHANNELS"]?,
      }
    end

    def parse_playlist_attributes(value)
      attributes = parse_attributes(value)
      resolution = parse_resolution(attributes["RESOLUTION"]?)
      {
        program_id: attributes["PROGRAM-ID"]?,
        codecs: attributes["CODECS"]?,
        width: resolution[:width]?,
        height: resolution[:height]?,
        bandwidth: attributes["BANDWIDTH"]?.try &.to_i,
        average_bandwidth: attributes["AVERAGE-BANDWIDTH"]?.try &.to_i,
        frame_rate: parse_frame_rate(attributes["FRAME-RATE"]?),
        video: attributes["VIDEO"]?,
        audio: attributes["AUDIO"]?,
        uri: attributes["URI"]?,
        subtitles: attributes["SUBTITLES"]?,
        closed_captions: attributes["CLOSED-CAPTIONS"]?,
        name: attributes["NAME"]?,
        hdcp_level: attributes["HDCP-LEVEL"]?
      }
    end

    def parse_session_data_attributes(text)
      attributes = parse_attributes(text)
      {
        data_id: attributes["DATA-ID"],
        value: attributes["VALUE"]?,
        uri: attributes["URI"]?,
        language: attributes["LANGUAGE"]?
      }
    end

    def parse_playback_start_attributes(text)
      attributes = parse_attributes(text)
      {
        time_offset: attributes["TIME-OFFSET"].to_f,
        precise: attributes["PRECISE"]?.try &.to_boolean,
      }
    end

    def parse_resolution(resolution)
      return { width: nil, height: nil } if resolution.nil?

      values = resolution.split('x')
      {
        width: values[0].to_i,
        height: values[1].to_i
      }
    end

    def parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal.new(frame_rate)
      value if value > 0
    end
  end
end
