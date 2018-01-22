# frozen_string_literal: true
require "./spec_helper"

module M3U8
  describe Parser do
    describe "#read" do
      it "parses master playlist" do
        file = File.read("spec/playlists/master.m3u8")
        playlist = Parser.read file
        playlist.master?.should be_true
        playlist.discontinuity_sequence.should be_nil
        playlist.independent_segments.should be_true

        item = playlist.items[0]
        item.should be_a(SessionKeyItem)
        item.method.should eq("AES-128")
        item.uri.should eq("https://priv.example.com/key.php?r=52")

        item = playlist.items[1]
        item.should be_a(PlaybackStart)
        item.time_offset.should eq(20.2)

        item = playlist.items[2]
        item.should be_a(PlaylistItem)
        item.uri.should eq("hls/1080-7mbps/1080-7mbps.m3u8")
        item.program_id.should eq(1)
        item.width.should eq(1920)
        item.height.should eq(1080)
        item.resolution.should eq("1920x1080")
        item.codecs.should eq("avc1.640028,mp4a.40.2")
        item.bandwidth.should eq(5_042_000)
        item.iframe.should be_false
        item.average_bandwidth.should be_nil

        item = playlist.items[7]
        item.should be_a(PlaylistItem)
        item.uri.should eq("hls/64k/64k.m3u8")
        item.program_id.should eq(1)
        item.width.should be_nil
        item.height.should be_nil
        item.resolution.should be_nil
        item.codecs.should eq("mp4a.40.2")
        item.bandwidth.should eq(6400)
        item.iframe.should be_false
        item.average_bandwidth.should be_nil

        playlist.items.size.should eq(8)

        item = playlist.items.last
        item.should be_a(PlaylistItem)
        item.resolution.should be_nil
      end

      it "parses master playlist with I-Frames" do
        file = File.read("spec/playlists/master_iframes.m3u8")
        playlist = Parser.read file

        playlist.master?.should be_true

        playlist.items.size.should eq(7)

        item = playlist.items[1]
        item.should be_a(PlaylistItem)
        item.bandwidth.should eq(86_000)
        item.iframe.should be_true
        item.uri.should eq("low/iframe.m3u8")
      end

      it "parses media playlist" do
        file = File.read("spec/playlists/playlist.m3u8")
        playlist = Parser.read file
        playlist.master?.should be_false
        playlist.version.should eq(4)
        playlist.sequence.should eq(1)
        playlist.discontinuity_sequence.should eq(8)
        playlist.cache.should be_false
        playlist.target.should eq(12)
        playlist.type.should eq("VOD")

        item = playlist.items[0]
        item.should be_a(SegmentItem)
        item.duration.should eq(11.344644)
        item.comment.should eq ""

        item = playlist.items[4]
        item.should be_a(TimeItem)
        item.time.should eq(Time.iso8601("2010-02-19T14:54:23Z"))

        playlist.items.size.should eq(140)
      end

      it "parses I-Frame playlist" do
        file = File.read("spec/playlists/iframes.m3u8")
        playlist = Parser.read file

        playlist.version.should eq(4)
        playlist.iframes_only.should be_true
        playlist.items.size.should eq(3)

        item = playlist.items[0]
        item.should be_a(SegmentItem)
        item.duration.should eq(4.12)
        item.segment.should eq("segment1.ts")

        item.byterange.should be_a(ByteRange)
        if item.is_a?(SegmentItem)
          item.byterange.length.should eq(9400)
          item.byterange.start.should eq(376)
        end

        item = playlist.items[1]
        if item.is_a?(SegmentItem)
          item.byterange.length.should eq(7144)
          item.byterange.start.should be_nil
        end
      end

      it "parses segment playlist with comments" do
        file = File.read("spec/playlists/playlist_with_comments.m3u8")
        playlist = Parser.read file
        playlist.master?.should be_false
        playlist.version.should eq(4)
        playlist.sequence.should eq(1)
        playlist.cache.should be_false
        playlist.target.should eq(12)
        playlist.type.should eq("VOD")

        item = playlist.items[0]
        item.should be_a(SegmentItem)
        item.duration.should eq(11.344644)
        item.comment.should eq("anything")

        item = playlist.items[1]
        item.should be_a(DiscontinuityItem)

        playlist.items.size.should eq(139)
      end

      it "parses variant playlist with audio options and groups" do
        file = File.read("spec/playlists/variant_audio.m3u8")
        playlist = Parser.read file

        playlist.master?.should be_true
        playlist.items.size.should eq(10)

        item = playlist.items[0]
        item.should be_a(MediaItem)
        item.type.should eq("AUDIO")
        item.group_id.should eq("audio-lo")
        item.language.should eq("eng")
        item.assoc_language.should eq("spoken")
        item.name.should eq("English")
        item.autoselect.should be_true
        item.default.should be_true
        item.uri.should eq("englo/prog_index.m3u8")
        item.forced.should be_true
      end

      it "parses variant playlist with camera angles" do
        file = File.read("spec/playlists/variant_angles.m3u8")
        playlist = Parser.read file

        playlist.master?.should be_true
        playlist.items.size.should eq(11)

        item = playlist.items[1]
        item.should be_a(MediaItem)
        item.type.should eq("VIDEO")
        item.group_id.should eq("200kbs")
        item.language.should be_nil
        item.name.should eq("Angle2")
        item.autoselect.should be_true
        item.default.should be_false
        item.uri.should eq("Angle2/200kbs/prog_index.m3u8")

        item = playlist.items[9]
        item.average_bandwidth.should eq(300_001)
        item.audio.should eq("aac")
        item.video.should eq("200kbs")
        item.closed_captions.should eq("captions")
        item.subtitles.should eq("subs")
      end

      it "processes multiple reads as separate playlists" do
        file = File.read("spec/playlists/master.m3u8")
        parser = Parser.new file
        playlist = parser.read

        playlist.items.size.should eq(8)

        file = File.read("spec/playlists/master.m3u8")
        playlist = parser.read file

        playlist.items.size.should eq(8)
      end

      it "parses playlist with session data" do
        file = File.read("spec/playlists/session_data.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(3)

        item = playlist.items[0]
        item.should be_a(SessionDataItem)
        item.data_id.should eq("com.example.lyrics")
        item.uri.should eq("lyrics.json")
      end

      it "parses encrypted playlist" do
        file = File.read("spec/playlists/encrypted.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(6)

        item = playlist.items[0]
        item.should be_a(KeyItem)
        item.method.should eq("AES-128")
        item.uri.should eq("https://priv.example.com/key.php?r=52")
      end

      it "parses map (media intialization section) playlists" do
        file = File.read("spec/playlists/map_playlist.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(1)

        item = playlist.items[0]
        item.should be_a(MapItem)
        item.uri.should eq("frelo/prog_index.m3u8")
        if item.is_a?(MapItem)
          item.byterange.length.should eq(4500)
          item.byterange.start.should eq(600)
        end
      end

      it "reads segment with timestamp" do
        file = File.read("spec/playlists/timestamp_playlist.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(6)

        item = playlist.items[0]
        item.should be_a(SegmentItem)
        if item.is_a?(SegmentItem)
          item.program_date_time.should be_a(TimeItem)
          item.program_date_time.time.should eq(Time.iso8601("2016-04-11T15:24:31Z"))
        end
      end

      it "parses playlist with daterange" do
        file = File.read("spec/playlists/date_range_scte35.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(5)

        item = playlist.items[0]
        item.should be_a(DateRangeItem)

        item = playlist.items[4]
        item.should be_a(DateRangeItem)
      end

      it "Live Media Playlist Using HTTPS" do
        file = File.read("spec/playlists/live_media_playlist.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(3)
        playlist.live?.should be_true
      end

      it "parsers playlist allow change line" do
        file = File.read("spec/playlists/change_line.m3u8")
        playlist = Parser.read file

        playlist.items.size.should eq(7)

        item = playlist.items[0]
        item.should be_a(MediaItem)
        item.uri.should eq "main/english-audio.m3u8"
      end

      context "when playlist source is invalid" do
        it "raises error with message" do
          message = "Playlist must start with a #EXTM3U tag, line read contained the value: /path/to/file"
          expect_raises(InvalidPlaylistError, message) do
            Parser.read("/path/to/file")
          end
        end
      end
    end
  end
end
