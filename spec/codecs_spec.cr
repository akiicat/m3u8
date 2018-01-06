require "./spec_helper"

module M3U8
  describe Codecs do
    {
      { NamedTuple.new, nil },
      { { codecs: "" }, nil },
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
    }.each do |(params, format)|
      item = Codecs.new(params)

      describe "initializes" do
        it "codecs" do
          item.codecs.should eq params[:codecs]?
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
      end

      it "generates codecs string from #{params} to #{format}" do
        item.to_s.should eq format
      end
    end
  end
end
