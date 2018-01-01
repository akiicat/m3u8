require "./spec_helper"

module M3U8
  describe PlaylistItem do

    describe "initialize" do
      options = {
        program_id: 1,
        width: 1920,
        height: 1080,
        codecs: "avc",
        bandwidth: 540,
        audio_codec: "mp3",
        level: "2",
        profile: "baseline",
        video: "test_video",
        audio: "test_a",
        uri: "test.url",
        average_bandwidth: 500,
        subtitles: "subs",
        closed_captions: "cc",
        iframe: true,
        frame_rate: 24.6,
        name: "test_name",
        hdcp_level: "TYPE-0",
      }

      expected = %(#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS="avc",BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO="test_a",VIDEO="test_video",SUBTITLES="subs",CLOSED-CAPTIONS="cc",NAME="test_name",URI="test.url")

      pending "hash" do
        PlaylistItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        PlaylistItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        PlaylistItem.new(**options).to_s.should eq expected
      end
    end

    {
      {
        {
          program_id: 1,
          width: 1920,
          height: 1080,
          codecs: "avc",
          bandwidth: 540,
          audio_codec: "mp3",
          level: "2",
          profile: "baseline",
          video: "test_video",
          audio: "test_a",
          uri: "test.url",
          average_bandwidth: 500,
          subtitles: "subs",
          closed_captions: "cc",
          iframe: true,
          frame_rate: 24.6,
          name: "test_name",
          hdcp_level: "TYPE-0",
          resolution: "1920x1080"
        },
        %(#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS="avc",BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO="test_a",VIDEO="test_video",SUBTITLES="subs",CLOSED-CAPTIONS="cc",NAME="test_name",URI="test.url")
      },
      {
        {
          bandwidth: 540,
          iframe: false
        },
        %(#EXT-X-STREAM-INF:BANDWIDTH=540\n)
      }
    }.each do |(params, format)|
      item = PlaylistItem.new(params)

      describe "initialize" do
        it "program_id" do
          item.program_id.should eq params[:program_id]?
        end

        it "width" do
          item.width.should eq params[:width]?
        end

        it "height" do
          item.height.should eq params[:height]?
        end

        it "resolution" do
          item.resolution.should eq params[:resolution]?
        end

        it "codecs" do
          item.codecs.should eq params[:codecs]?
        end

        it "bandwidth" do
          item.bandwidth.should eq params[:bandwidth]
        end

        it "audio_codec" do
          item.audio_codec.should eq params[:audio_codec]?
        end

        it "level" do
          level = params[:level]?
          item.level.should eq level ? level.to_f : nil
        end

        it "profile" do
          item.profile.should eq params[:profile]?
        end

        it "video" do
          item.video.should eq params[:video]?
        end

        it "audio" do
          item.audio.should eq params[:audio]?
        end

        it "uri" do
          item.uri.should eq params[:uri]?
        end

        it "average_bandwidth" do
          item.average_bandwidth.should eq params[:average_bandwidth]?
        end

        it "subtitles" do
          item.subtitles.should eq params[:subtitles]?
        end

        it "closed_captions" do
          item.closed_captions.should eq params[:closed_captions]?
        end

        it "iframe" do
          item.iframe.should eq params[:iframe]?
        end

        it "frame_rate" do
          item.frame_rate.should eq params[:frame_rate]?
        end

        it "name" do
          item.name.should eq params[:name]?
        end

        it "hdcp_level" do
          item.hdcp_level.should eq params[:hdcp_level]?
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end


    # describe ".parse" do
    #   it "returns new instance from parsed tag" do
    #     tag = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
    #       %(PROGRAM-ID=1,RESOLUTION=1920x1080,FRAME-RATE=23.976,) +
    #       %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
    #       %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url",) +
    #       %(NAME="1080p",HDCP-LEVEL=TYPE-0)
    #     expect_any_instance_of(described_class).to receive(:parse).with(tag)
    #     item = described_class.parse(tag)
    #     expect(item).to be_a(described_class)
    #   end
    # end

    # describe "#parse" do
    #   it "assigns values from parsed tag" do
    #     input = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
    #       %(PROGRAM-ID=1,RESOLUTION=1920x1080,FRAME-RATE=23.976,) +
    #       %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
    #       %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url",) +
    #       %(NAME="1080p",HDCP-LEVEL=TYPE-0)
    #     item = M3u8::PlaylistItem.parse(input)
    #     expect(item.program_id).to eq "1"
    #     expect(item.codecs).to eq "avc"
    #     expect(item.bandwidth).to eq 540
    #     expect(item.average_bandwidth).to eq 550
    #     expect(item.width).to eq 1920
    #     expect(item.height).to eq 1080
    #     expect(item.frame_rate).to eq BigDecimal("23.976")
    #     expect(item.audio).to eq "test"
    #     expect(item.video).to eq "test2"
    #     expect(item.subtitles).to eq "subs"
    #     expect(item.closed_captions).to eq "caps"
    #     expect(item.uri).to eq "test.url"
    #     expect(item.name).to eq "1080p"
    #     expect(item.iframe).to be false
    #     expect(item.hdcp_level).to eq("TYPE-0")
    #   end
    # end

    describe "to_s" do
      describe "does not specify CODECS" do
        {
          {
            "when codecs is missing",
            { bandwidth: 540, uri: "test.url" }
          },
          {
            "when level is not recognized",
            { bandwidth: 540, uri: "test.url", level: 9001 }
          },
          {
            "when profile is not recognized",
            { bandwidth: 540, uri: "test.url", profile: "best" }
          },
          {
            "when profile and level are not recognized",
            { bandwidth: 540, uri: "test.url", profile: "best", level: 9001 }
          },
          {
            "when audio codec is recognized",
            { bandwidth: 540, uri: "test.url", profile: "best", level: 9001, audio_codec: "aac-lc" }
          },
          {
            "when profile and level and audio codec are recognized",
            { bandwidth: 540, uri: "test.url", profile: "high", level: 4.1, audio_codec: "fuzzy" }
          }

        }.each do |(description, params)|
          item = PlaylistItem.new params

          it description do
            item.to_s.should_not contain "CODECS"
          end
        end
      end


      {
        {
          "when profile and level are not set" + "when audio codec is recognized" + "specifies CODECS with audio codec",
          { bandwidth: 540, uri: "test.url", audio_codec: "aac-lc" },
          %(CODECS="mp4a.40.2")
        },
        {
          "when profile and level are recognized" + "when audio codec is not set" + "specifies CODECS with video codec",
          { bandwidth: 540, uri: "test.url", profile: "high", level: 4.1 },
          %(CODECS="avc1.640029")
        },
        {
          "when profile and level are recognized" + "when audio codec is recognized" + "specifies CODECS with video codec and audio_codec",
          { bandwidth: 540, uri: "test.url", profile: "high", level: 4.1, audio_codec: "aac-lc" },
          %(CODECS="avc1.640029,mp4a.40.2")
        }
      }.each do |(description, params, format)|
        item = PlaylistItem.new params

        it description do
          item.to_s.should contain format
        end
      end


      describe "returns tag" do
        {
          {
            "when only required attributes are present",
            { codecs: "avc", bandwidth: 540, uri: "test.url" },
            %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540\ntest.url)
          },
          {
            "when all attributes are present",
            {
              codecs: "avc", bandwidth: 540, uri: "test.url",
              audio: "test", video: "test2", average_bandwidth: 500,
              subtitles: "subs", frame_rate: 30, closed_captions: "caps",
              name: "SD", hdcp_level: "TYPE-0", program_id: "1"
            },
            %(#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS="avc",) +
            "BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=30.000," \
            "HDCP-LEVEL=TYPE-0," +
            %(AUDIO="test",VIDEO="test2",SUBTITLES="subs",) +
            %(CLOSED-CAPTIONS="caps",NAME="SD"\ntest.url)
          },
          {
            "when closed captions is NONE",
            {
              program_id: 1, width: 1920, height: 1080, codecs: "avc",
              bandwidth: 540, uri: "test.url", closed_captions: "NONE"
            },
            "#EXT-X-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080," +
            %(CODECS="avc",BANDWIDTH=540,CLOSED-CAPTIONS=NONE\ntest.url)
          },
          {
            "when iframe is enabled" + "returns EXT-X-I-FRAME-STREAM-INF tag",
            {
              codecs: "avc", bandwidth: 540, uri: "test.url",
              iframe: true, video: "test2", average_bandwidth: 550
            },
            %(#EXT-X-I-FRAME-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
            %(AVERAGE-BANDWIDTH=550,VIDEO="test2",URI="test.url")
          }
        }.each do |(description, params, format)|
          item = PlaylistItem.new params

          it description do
            item.to_s.should eq format
          end
        end
      end

      describe "generates codecs string" do
        {
          { NamedTuple.new, nil },
          { { codecs: "test" }, "test" },
          { { audio_codec: "aac-lc" }, "mp4a.40.2" },
          { { audio_codec: "AAC-LC" }, "mp4a.40.2" },
          { { audio_codec: "he-aac" }, "mp4a.40.5" },
          { { audio_codec: "HE-AAC" }, "mp4a.40.5" },
          { { audio_codec: "he-acc1" }, nil },
          { { audio_codec: "mp3" }, "mp4a.40.34" },
          { { audio_codec: "MP3" }, "mp4a.40.34" },
          { { profile: "baseline", level: 3.0 }, "avc1.66.30" },
          { { profile: "baseline", level: 3.0, audio_codec: "aac-lc" }, "avc1.66.30,mp4a.40.2" },
          { { profile: "baseline", level: 3.0, audio_codec: "mp3" }, "avc1.66.30,mp4a.40.34" },
          { { profile: "baseline", level: 3.1 }, "avc1.42001f" },
          { { profile: "baseline", level: 3.1, audio_codec: "he-aac" }, "avc1.42001f,mp4a.40.5" },
          { { profile: "main", level: 3.0 }, "avc1.77.30" },
          { { profile: "main", level: 3.0, audio_codec: "aac-lc" }, "avc1.77.30,mp4a.40.2" },
          { { profile: "main", level: 3.1 }, "avc1.4d001f" },
          { { profile: "main", level: 4.0 }, "avc1.4d0028" },
          { { profile: "main", level: 4.1 }, "avc1.4d0029" },
          { { profile: "high", level: 3.1 }, "avc1.64001f" },
          { { profile: "high", level: 4.0 }, "avc1.640028" },
          { { profile: "high", level: 4.1 }, "avc1.640029" }
        }.each do |(params, codecs)|
          item = PlaylistItem.new params

          it "#{params} to #{codecs}" do
            item.codecs.should eq codecs
          end
        end
      end
    end
  end
end