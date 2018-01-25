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
          bandwidth: 540,
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
          codecs: "avc",
          audio_codec: "mp3",
          level: "2",
          profile: "baseline",
        },
        %(#EXT-X-I-FRAME-STREAM-INF:PROGRAM-ID=1,RESOLUTION=1920x1080,CODECS="avc",BANDWIDTH=540,AVERAGE-BANDWIDTH=500,FRAME-RATE=24.600,HDCP-LEVEL=TYPE-0,AUDIO="test_a",VIDEO="test_video",SUBTITLES="subs",CLOSED-CAPTIONS="cc",NAME="test_name",URI="test.url"),
        { resolution: "1920x1080", codecs: "avc" }
      },
      {
        {
          bandwidth: 540,
          iframe: false
        },
        %(#EXT-X-STREAM-INF:BANDWIDTH=540\n),
        { resolution: nil, codecs: nil }
      }
    }.each do |(params, format, options)|
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
          item.resolution.should eq options[:resolution]?
        end

        it "codecs" do
          item.codecs.should eq options[:codecs]?.to_s
        end

        it "bandwidth" do
          item.bandwidth.should eq params[:bandwidth]
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


    describe ".parse" do
      it "returns new instance from parsed tag" do
        tag = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
          %(PROGRAM-ID=1,RESOLUTION=1920x1080,FRAME-RATE=23.976,) +
          %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
          %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url",) +
          %(NAME="1080p",HDCP-LEVEL=TYPE-0)
        item = PlaylistItem.parse(tag)
        item.should be_a(PlaylistItem)
      end
    end

    describe "#parse" do
      it "assigns values from parsed tag" do
        input = %(#EXT-X-STREAM-INF:CODECS="avc",BANDWIDTH=540,) +
          %(PROGRAM-ID=1,RESOLUTION=1920x1080,FRAME-RATE=23.976,) +
          %(AVERAGE-BANDWIDTH=550,AUDIO="test",VIDEO="test2",) +
          %(SUBTITLES="subs",CLOSED-CAPTIONS="caps",URI="test.url",) +
          %(NAME="1080p",HDCP-LEVEL=TYPE-0)
        item = PlaylistItem.parse(input)
        item.program_id.should eq 1
        item.codecs.should eq "avc"
        item.bandwidth.should eq 540
        item.average_bandwidth.should eq 550
        item.width.should eq 1920
        item.height.should eq 1080
        item.frame_rate.should eq 23.976
        item.audio.should eq "test"
        item.video.should eq "test2"
        item.subtitles.should eq "subs"
        item.closed_captions.should eq "caps"
        item.uri.should eq "test.url"
        item.name.should eq "1080p"
        item.iframe.should be_false
        item.hdcp_level.should eq("TYPE-0")
      end
    end

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
          "when profile and level are not set, when audio codec is recognized, specifies CODECS with audio codec",
          { bandwidth: 540, uri: "test.url", audio_codec: "aac-lc" },
          %(CODECS="mp4a.40.2")
        },
        {
          "when profile and level are recognized, when audio codec is not set, specifies CODECS with video codec",
          { bandwidth: 540, uri: "test.url", profile: "high", level: 4.1 },
          %(CODECS="avc1.640029")
        },
        {
          "when profile and level are recognized, when audio codec is recognized, specifies CODECS with video codec and audio_codec",
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
    end
  end
end
