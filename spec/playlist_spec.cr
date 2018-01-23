require "./spec_helper"

module M3U8
  describe Playlist do
    describe "#new" do
      it "initializes with defaults" do
        playlist = Playlist.new
        playlist.version.should be_nil
        playlist.cache.should be_nil
        playlist.target.should eq(10)
        playlist.sequence.should eq(0)
        playlist.discontinuity_sequence.should be_nil
        playlist.type.should be_nil
        playlist.iframes_only.should be_false
        playlist.independent_segments.should be_false
      end

      it "initializes from options" do
        options = {
          version: 7,
          cache: false,
          target: 12,
          sequence: 1,
          discontinuity_sequence: 2,
          type: "VOD",
          independent_segments: true
        }
        playlist = Playlist.new(options)
        playlist.version.should eq(7)
        playlist.cache.should be_false
        playlist.target.should eq(12)
        playlist.sequence.should eq(1)
        playlist.discontinuity_sequence.should eq(2)
        playlist.type.should eq("VOD")
        playlist.iframes_only.should be_false
        playlist.independent_segments.should be_true
      end

      it "initializes as master playlist" do
        options = {
          master: true
        }
        playlist = Playlist.new(options)
        playlist.master?.should be_true
      end
    end

    describe ".codecs" do
      it "generates codecs string" do
        options = {
          profile: "baseline",
          level: 3.0,
          audio_codec: "aac-lc"
        }
        Playlist.codecs(options).should eq("avc1.66.30,mp4a.40.2")
      end
    end

    describe ".read" do
      it "returns new playlist from content" do
        file = File.read("spec/playlists/master.m3u8")
        playlist = Playlist.parse(file)
        playlist.master?.should be_true
        playlist.items.size.should eq(8)
      end
    end

    describe "#duration" do
      it "should return the total duration of a playlist" do
        playlist = Playlist.new

        playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
        playlist.items << SegmentItem.new(duration: 9.891, segment: "test_02.ts")
        playlist.items << SegmentItem.new(duration: 10.556, segment: "test_03.ts")
        playlist.items << SegmentItem.new(duration: 8.790, segment: "test_04.ts")

        playlist.duration.round(3).should eq(40.228)
      end
    end

    describe "#master?" do
      context "when playlist is a master playlist" do
        it "returns true" do
          playlist = Playlist.new

          options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          playlist.master?.should be_true
        end
      end

      context "when playlist is a media playlist" do
        it "returns false" do
          playlist = Playlist.new
          playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
          playlist.master?.should be_false
        end
      end

      context "when playlist is a new playlist" do
        it "returns false" do
          playlist = Playlist.new
          playlist.master?.should be_false
        end
      end

      context "when a new playlist is set as master" do
        it "returns true" do
          playlist = Playlist.new(master: true)
          playlist.master?.should be_true
        end
      end

      context "when a new playlist is set as not master" do
        it "returns false" do
          playlist = Playlist.new(master: false)
          playlist.master?.should be_false
        end
      end
    end

    describe "#live?" do
      context "when playlist is a master playlist" do
        it "returns false" do
          playlist = Playlist.new

          options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          playlist.live.should be_false
        end
      end

      context "when playlist is a media playlist and set as live" do
        it "returns true" do
          playlist = Playlist.new(live: true)
          playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
          playlist.live?.should be_true
        end
      end

      context "when a new playlist is set as not live" do
        it "returns false" do
          playlist = Playlist.new(live: false)
          playlist.live.should be_false
        end
      end

      context "when playlist is a new playlist" do
        it "returns false" do
          playlist = Playlist.new
          playlist.live?.should be_false
        end
      end
    end

    describe "#to_s" do
      it "returns master playlist text" do
        playlist = Playlist.new

        options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
        playlist.items << PlaylistItem.new(options)

        options = { program_id: "2", uri: "playlist_url", bandwidth: 50_000, width: 1920, height: 1080, profile: "high", level: 4.1, audio_codec: "aac-lc" }
        playlist.items << PlaylistItem.new(options)

        expected = 
          %(#EXTM3U\n) \
          %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") \
          %(,BANDWIDTH=6400\nplaylist_url\n) \
          %(#EXT-X-STREAM-INF:PROGRAM-ID=2,) \
          %(RESOLUTION=1920x1080,CODECS="avc1.640029,mp4a.40.2") \
          %(,BANDWIDTH=50000\nplaylist_url\n)

        playlist.to_s.should eq(expected)
      end

      it "returns media playlist text" do
        playlist = Playlist.new

        options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
        playlist.items << SegmentItem.new(options)

        options = { duration: 11.261233, segment: "1080-7mbps00001.ts" }
        playlist.items << SegmentItem.new(options)

        expected =
          %(#EXTM3U\n) \
          %(#EXT-X-MEDIA-SEQUENCE:0\n) \
          %(#EXT-X-TARGETDURATION:10\n) \
          %(#EXTINF:11.344644,\n) \
          %(1080-7mbps00000.ts\n) \
          %(#EXTINF:11.261233,\n) \
          %(1080-7mbps00001.ts\n) \
          %(#EXT-X-ENDLIST\n)
        playlist.to_s.should eq(expected)
      end
    end

    describe "#valid?" do
      context "when playlist is valid" do
        it "returns true" do
          playlist = Playlist.new

          playlist.valid?.should be_true

          options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url" }
          playlist.items << PlaylistItem.new(options)

          playlist.valid?.should be_true

          options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url" }
          playlist.items << PlaylistItem.new(options)

          playlist.valid?.should be_true
        end
      end

      context "when playlist is invalid" do
        it "returns false" do
          playlist = Playlist.new

          options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url" }
          playlist.items << PlaylistItem.new(options)

          playlist.valid?.should be_true

          options = { duration: 10.991, segment: "test.ts" }
          playlist.items << SegmentItem.new(options)

          playlist.valid?.should be_false
        end
      end
    end

    describe "#header_attributes" do
      context "when playlist is a master playlist" do
        it "writes header content only" do
          playlist = Playlist.new(version: 6, independent_segments: true)

          options = { uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          expected =
            "#EXTM3U\n" \
            "#EXT-X-VERSION:6\n" \
            "#EXT-X-INDEPENDENT-SEGMENTS"

          playlist.master?.should be_true
          playlist.header.should eq(expected)
        end
      end

      context "when playlist is a media playlist" do
        it "writes header content only" do
          playlist = Playlist.new(version: 7)

          options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
          playlist.items << SegmentItem.new(options)

          expected =
            "#EXTM3U\n" \
            "#EXT-X-VERSION:7\n" \
            "#EXT-X-MEDIA-SEQUENCE:0\n" \
            "#EXT-X-TARGETDURATION:10"

          playlist.header.should eq(expected)
        end
      end
    end

    describe "#footer_attributes" do
      context "when playlist is a master playlist" do
        it "does nothing" do
          playlist = Playlist.new(master: true)
          playlist.footer.should eq ""
        end
      end

      context "when playlist is a media playlist" do
        it "writes end list tag" do
          playlist = Playlist.new(master: false)
          playlist.footer.should eq("#EXT-X-ENDLIST")
        end
      end
    end

    describe "#write" do
      context "when playlist is valid" do
        it "returns playlist text" do
          playlist = Playlist.new

          options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          expected =
            %(#EXTM3U\n) \
            %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34",) \
            %(BANDWIDTH=6400\nplaylist_url\n)

          playlist.to_s.should eq(expected)
        end
      end

      context "when item types are invalid" do
        it "raises error" do
          playlist = Playlist.new

          options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, uri: "test.url" }
          playlist.items << PlaylistItem.new(options)

          options = { duration: 10.991, segment: "test.ts" }
          playlist.items << SegmentItem.new(options)

          message = "Playlist is invalid."

          expect_raises(PlaylistTypeError, message) do
            playlist.to_s
          end
        end
      end
    end

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

          expected =
            %(#EXTM3U\n) \
            %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") \
            %(,BANDWIDTH=6400\nplaylist_url\n) \
            %(#EXT-X-STREAM-INF:PROGRAM-ID=2,) \
            %(RESOLUTION=1920x1080,CODECS="avc1.640029,mp4a.40.2") \
            %(,BANDWIDTH=50000\nplaylist_url\n) \
            %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) \
            %(VALUE="Test",URI="http://test",LANGUAGE="en"\n)

          playlist.to_s.should eq(expected)
        end
      end

      context "when playlist is a master playlist with single stream" do
        it "writes playlist to io" do
          playlist = Playlist.new

          options = { program_id: "1", uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          expected =
            %(#EXTM3U\n) \
            %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="mp4a.40.34") \
            %(,BANDWIDTH=6400\nplaylist_url\n)

          playlist.to_s.should eq(expected)
        end
      end

      context "when playlist is a master playlist with header options" do
        it "writes playlist to io" do
          playlist = Playlist.new(version: 6, independent_segments: true)

          options = { uri: "playlist_url", bandwidth: 6400, audio_codec: "mp3" }
          playlist.items << PlaylistItem.new(options)

          expected =
            %(#EXTM3U\n) \
            %(#EXT-X-VERSION:6\n) \
            %(#EXT-X-INDEPENDENT-SEGMENTS\n) \
            %(#EXT-X-STREAM-INF:CODECS="mp4a.40.34") \
            %(,BANDWIDTH=6400\nplaylist_url\n)

          playlist.to_s.should eq(expected)
        end
      end

      context "when playlist is a new master playlist" do
        it "writes playlist to io" do
          playlist = Playlist.new(master: true)
          playlist.to_s.should eq("#EXTM3U\n")
        end
      end

      context "when playlist is a new media playlist" do
        it "writes playlist to io" do

          expected =
            "#EXTM3U\n" \
            "#EXT-X-MEDIA-SEQUENCE:0\n" \
            "#EXT-X-TARGETDURATION:10\n" \
            "#EXT-X-ENDLIST\n"

          playlist = Playlist.new
          playlist.to_s.should eq(expected)
        end
      end

      context "when playlist is a media playlist" do
        it "writes playlist to io" do
          options = { version: 4, cache: false, target: 6.2, sequence: 1, discontinuity_sequence: 10, type: "EVENT", iframes_only: true }
          playlist = Playlist.new(options)
          
          options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
          playlist.items << SegmentItem.new(options)

          expected =
            "#EXTM3U\n" \
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

          playlist.to_s.should eq(expected)
        end
      end

      context "when playlist is media playlist with keys" do
        it "writes playlist to io" do
          playlist = Playlist.new(version: 7)

          options = { duration: 11.344644, segment: "1080-7mbps00000.ts" }
          playlist.items << SegmentItem.new(options)

          options = { method: "AES-128", uri: "http://test.key", iv: "D512BBF", key_format: "identity", key_format_versions: "1/3" }
          playlist.items << KeyItem.new(options)

          options = { duration: 11.261233, segment: "1080-7mbps00001.ts" }
          playlist.items << SegmentItem.new(options)

          expected =
            %(#EXTM3U\n) \
            %(#EXT-X-VERSION:7\n) \
            %(#EXT-X-MEDIA-SEQUENCE:0\n) \
            %(#EXT-X-TARGETDURATION:10\n) \
            %(#EXTINF:11.344644,\n) \
            %(1080-7mbps00000.ts\n) \
            %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",) \
            %(IV=D512BBF,KEYFORMAT="identity",) \
            %(KEYFORMATVERSIONS="1/3"\n) \
            %(#EXTINF:11.261233,\n) \
            %(1080-7mbps00001.ts\n) \
            %(#EXT-X-ENDLIST\n)

          playlist.to_s.should eq(expected)
        end
      end

      it "raises error if item types are mixed" do
        playlist = Playlist.new

        options = { program_id: 1, width: 1920, height: 1080, codecs: "avc", bandwidth: 540, playlist: "test.url" }
        playlist.items << PlaylistItem.new(options)

        options = { duration: 10.991, segment: "test.ts" }
        playlist.items << SegmentItem.new(options)

        message = "Playlist is invalid."
        
        expect_raises(PlaylistTypeError, message) do
          playlist.to_s
        end
      end
    end
  end
end
