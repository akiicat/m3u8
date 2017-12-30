require "./spec_helper"

module M3U8
  describe Writer do
    describe "#write" do
      context "when playlist is a master playlist" do
        it "writes playlist to io" do
          playlist = Playlist.new
          options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)
          options = { program_id: "2", uri: "playlist_url", bandwidth: 50_000, width: 1920, height: 1080, profile: "high", level: 4.1, audio_codec: "aac-lc" }
          playlist.items << PlaylistItem.new(options)
          options = { data_id: "com.test.movie.title", value: "Test", uri: "http://test", language: "en" }
          playlist.items << SessionDataItem.new(options)

          expected = "#EXTM3U\n" +
            %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
            ",BANDWIDTH=6400\nplaylist_url\n" \
            "#EXT-X-STREAM-INF:PROGRAM-ID=2," +
            %(RESOLUTION=1920x1080,CODECS="avc1.640029,mp4a.40.2") +
            ",BANDWIDTH=50000\nplaylist_url\n" +
            %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
            %(VALUE="Test",URI="http://test",LANGUAGE="en"\n)

          writer = Writer.new
          writer.write(playlist)
          writer.to_s.should eq(expected)
        end
      end

      context "when playlist is a master playlist with single stream" do
        it "writes playlist to io" do
          playlist = Playlist.new

          options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          expected = "#EXTM3U\n" +
            %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") +
            ",BANDWIDTH=6400\nplaylist_url\n"

          writer = Writer.new
          writer.write(playlist)
          writer.to_s.should eq(expected)
        end
      end

      context "when playlist is a master playlist with header options" do
        it "writes playlist to io" do
          options = { uri: "playlist_url", bandwidth: 6400,
                      audio_codec: "mp3" }
          playlist = Playlist.new({version: 6, independent_segments: true})
          playlist.items << PlaylistItem.new(options)

          expected = "#EXTM3U\n" \
            "#EXT-X-VERSION:6\n" \
            "#EXT-X-INDEPENDENT-SEGMENTS\n" +
            %(#EXT-X-STREAM-INF:CODECS="mp4a.40.34") +
            ",BANDWIDTH=6400\nplaylist_url\n"

          writer = Writer.new
          writer.write(playlist)
          writer.to_s.should eq(expected)
        end
      end

      context "when playlist is a new master playlist" do
        it "writes playlist to io" do
          writer = Writer.new
          playlist = Playlist.new({master: true})
          writer.write(playlist)
          writer.to_s.should eq("#EXTM3U\n")
        end
      end

      context "when playlist is a new media playlist" do
        it "writes playlist to io" do
          expected = "#EXTM3U\n" \
            "#EXT-X-MEDIA-SEQUENCE:0\n" \
            "#EXT-X-TARGETDURATION:10\n" \
            "#EXT-X-ENDLIST\n"

          writer = Writer.new
          writer.write(Playlist.new)
          writer.to_s.should eq(expected)
        end
      end

      context "when playlist is a media playlist" do
        it "writes playlist to io" do
          options = { version: 4, cache: false, target: 6.2, sequence: 1,
                      discontinuity_sequence: 10, type: "EVENT",
                      iframes_only: true }

          playlist = Playlist.new(options)
          options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
          playlist.items << SegmentItem.new(options)

          expected = "#EXTM3U\n" \
            "#EXT-X-PLAYLIST-TYPE:EVENT\n" \
            "#EXT-X-VERSION:4\n" \
            "#EXT-X-I-FRAMES-ONLY\n" \
            "#EXT-X-MEDIA-SEQUENCE:1\n" \
            "#EXT-X-DISCONTINUITY-SEQUENCE:10\n" \
            "#EXT-X-ALLOW-CACHE:NO\n" \
            "#EXT-X-TARGETDURATION:6\n" \
            "#EXTINF:11.344644,\n" \
            "1080-7mbps00000.ts\n" \
            "#EXT-X-ENDLIST\n"

          writer = Writer.new
          writer.write(playlist)
          writer.to_s.should eq(expected)
        end
      end

      context "when playlist is media playlist with keys" do
        it "writes playlist to io" do
          playlist = Playlist.new({version: 7})

          options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
          playlist.items << SegmentItem.new(options)

          options = { method: "AES-128", uri: "http://test.key",
                      iv: "D512BBF", key_format: "identity",
                      key_format_versions: "1/3" }
          playlist.items << KeyItem.new(options)

          options = { duration: 11.261233, segment: "1080-7mbps00001.ts" }
          playlist.items << SegmentItem.new(options)

          expected = "#EXTM3U\n" \
            "#EXT-X-VERSION:7\n" \
            "#EXT-X-MEDIA-SEQUENCE:0\n" \
            "#EXT-X-TARGETDURATION:10\n" \
            "#EXTINF:11.344644,\n" \
            "1080-7mbps00000.ts\n" +
            %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",) +
            %(IV=D512BBF,KEYFORMAT="identity",) +
            %(KEYFORMATVERSIONS="1/3"\n) +
            "#EXTINF:11.261233,\n" \
            "1080-7mbps00001.ts\n" \
            "#EXT-X-ENDLIST\n"

          writer = Writer.new
          writer.write(playlist)
          writer.to_s.should eq(expected)
        end
      end

      it "raises error if item types are mixed" do
        playlist = Playlist.new
        options = { program_id: 1, width: 1920, height: 1080, codecs: "avc",
                    bandwidth: 540, playlist: "test.url" }
        playlist.items << PlaylistItem.new(options)

        options = { duration: 10.991, segment: "test.ts" }
        playlist.items << SegmentItem.new(options)

        message = "Playlist is invalid."
        writer = Writer.new
        
        expect_raises(PlaylistTypeError, message) do
          writer.write(playlist)
        end
      end
    end

    describe "#write_footer" do
      context "when playlist is a master playlist" do
        it "does nothing" do
          writer = Writer.new
          playlist = Playlist.new({master: true})
          writer.write_footer(playlist)

          writer.to_s.should eq ""
        end
      end

      context "when playlist is a media playlist" do
        it "writes end list tag" do
          writer = Writer.new
          playlist = Playlist.new({master: false})
          writer.write_footer(playlist)

          writer.to_s.should eq("#EXT-X-ENDLIST\n")
        end
      end
    end

    describe "#write_header" do
      context "when playlist is a master playlist" do
        it "writes header content only" do
          playlist = Playlist.new({version: 6, independent_segments: true})
          options = { uri: "playlist_url", bandwidth: 6400,
                      audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)
          playlist.master?.should be_true

          expected = "#EXTM3U\n" \
            "#EXT-X-VERSION:6\n" \
            "#EXT-X-INDEPENDENT-SEGMENTS\n"

          writer = Writer.new
          writer.write_header(playlist)
          writer.to_s.should eq(expected)
        end
      end

      context "when playlist is a media playlist" do
        it "writes header content only" do
          playlist = Playlist.new({version: 7})
          options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
          playlist.items << SegmentItem.new(options)

          writer = Writer.new
          writer.write_header(playlist)

          expected = "#EXTM3U\n" \
            "#EXT-X-VERSION:7\n" \
            "#EXT-X-MEDIA-SEQUENCE:0\n" \
            "#EXT-X-TARGETDURATION:10\n"

          writer.to_s.should eq(expected)
        end
      end
    end
  end
end
