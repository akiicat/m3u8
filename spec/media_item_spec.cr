require "./spec_helper"

module M3U8
  describe MediaItem do

    {
      {
        {
          type: "AUDIO",
          group_id: "audio-lo",
          language: "fre",
          assoc_language: "spoken",
          name: "Francais",
          autoselect: true,
          default: false,
          forced: true,
          uri: "frelo/prog_index.m3u8",
          instream_id: "SERVICE3",
          characteristics: "public.html",
          channels: "6"
        },
        %(#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",) + 
        %(LANGUAGE="fre",ASSOC-LANGUAGE="spoken",) +
        %(NAME="Francais",AUTOSELECT=YES,) +
        %(DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES,) +
        %(INSTREAM-ID="SERVICE3",CHARACTERISTICS="public.html",) +
        %(CHANNELS="6")
      },
      {
        {
          type: "AUDIO",
          group_id: "audio-lo",
          name: "Francais"
        },
        %(#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",NAME="Francais")
      },
      {
        NamedTuple.new,
        %(#EXT-X-MEDIA:TYPE=,GROUP-ID="",NAME="")
      }
    }.each do |(params, format)|
      item = MediaItem.new(params)

      describe "initialize" do
        it "type" do
          item.type.should eq params[:type]?
        end

        it "group_id" do
          item.group_id.should eq params[:group_id]?
        end

        it "language" do
          item.language.should eq params[:language]?
        end

        it "assoc_language" do
          item.assoc_language.should eq params[:assoc_language]?
        end

        it "name" do
          item.name.should eq params[:name]?
        end

        it "autoselect" do
          item.autoselect.should eq params[:autoselect]?
        end

        it "default" do
          item.default.should eq params[:default]?
        end

        it "uri" do
          item.uri.should eq params[:uri]?
        end

        it "forced" do
          item.forced.should eq params[:forced]?
        end

        it "instream_id" do
          item.instream_id.should eq params[:instream_id]?
        end

        it "characteristics" do
          item.characteristics.should eq params[:characteristics]?
        end

        it "channels" do
          item.channels.should eq params[:channels]?
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end

    # describe ".parse" do
    #   it "returns instance from parsed tag" do
    #     tag = "#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",LANGUAGE="fre"," \
    #           "ASSOC-LANGUAGE="spoken",NAME="Francais",AUTOSELECT=YES," \
    #           "INSTREAM-ID="SERVICE3",CHARACTERISTICS="public.html"," \
    #           "CHANNELS="6"," +
    #           %("DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES\n")
    #     item = described_class.parse(tag)

    #     expect(item.type).to eq("AUDIO")
    #     expect(item.group_id).to eq("audio-lo")
    #     expect(item.language).to eq("fre")
    #     expect(item.assoc_language).to eq("spoken")
    #     expect(item.name).to eq("Francais")
    #     expect(item.autoselect).to be true
    #     expect(item.default).to be false
    #     expect(item.uri).to eq("frelo/prog_index.m3u8")
    #     expect(item.forced).to be true
    #     expect(item.instream_id).to eq("SERVICE3")
    #     expect(item.characteristics).to eq("public.html")
    #     expect(item.channels).to eq("6")
    #   end
    # end
  end
end
