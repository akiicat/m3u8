module M3U8
  # Writer provides generation of text output of playlists in m3u8 format
  class Writer
    property io : String::Builder

    def initialize(io = String::Builder.new)
      @io = io
    end

    def write(playlist)
      validate(playlist)
      write_header(playlist)

      playlist.items.each do |item|
        @io.puts item.to_s
      end

      write_footer(playlist)
    end

    def write_header(playlist)
      @io.puts "#EXTM3U"
      if playlist.master?
        write_master_playlist_header(playlist)
      else
        write_media_playlist_header(playlist)
      end
    end

    def write_footer(playlist)
      @io.puts "#EXT-X-ENDLIST" unless playlist.live? || playlist.master?
    end

    def to_s
      @io.to_s
    end

    # private

    def target_duration_format(playlist)
      "#EXT-X-TARGETDURATION:%d" % playlist.target
    end

    def validate(playlist)
      raise PlaylistTypeError.new("Playlist is invalid.") unless playlist.valid?
    end

    def write_cache_tag(cache)
      @io.puts "#EXT-X-ALLOW-CACHE:#{cache.to_yes_no}" unless cache.nil?
    end

    def write_discontinuity_sequence_tag(sequence)
      @io.puts "#EXT-X-DISCONTINUITY-SEQUENCE:#{sequence}" unless sequence.nil?
    end

    def write_independent_segments_tag(independent_segments)
      @io.puts "#EXT-X-INDEPENDENT-SEGMENTS" if independent_segments
    end

    def write_master_playlist_header(playlist)
      write_version_tag(playlist.version)
      write_independent_segments_tag(playlist.independent_segments)
    end

    def write_media_playlist_header(playlist)
      @io.puts "#EXT-X-PLAYLIST-TYPE:#{playlist.type}" unless playlist.type.nil?
      write_version_tag(playlist.version)
      write_independent_segments_tag(playlist.independent_segments)
      @io.puts "#EXT-X-I-FRAMES-ONLY" if playlist.iframes_only
      @io.puts "#EXT-X-MEDIA-SEQUENCE:#{playlist.sequence}"
      write_discontinuity_sequence_tag(playlist.discontinuity_sequence)
      write_cache_tag(playlist.cache)
      @io.puts target_duration_format(playlist)
    end

    def write_version_tag(version)
      @io.puts "#EXT-X-VERSION:#{version}" unless version.nil?
    end
  end
end
