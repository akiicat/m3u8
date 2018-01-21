require "./spec_helper"

module M3U8
  describe MediaItem do
    describe "initialize" do
      options = {
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
      }
      expected =
        %(#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-lo",) +
        %(LANGUAGE="fre",ASSOC-LANGUAGE="spoken",) +
        %(NAME="Francais",AUTOSELECT=YES,) +
        %(DEFAULT=NO,URI="frelo/prog_index.m3u8",FORCED=YES,) +
        %(INSTREAM-ID="SERVICE3",CHARACTERISTICS="public.html",) +
        %(CHANNELS="6")

      pending "hash" do
        MediaItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        MediaItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        MediaItem.new(**options).to_s.should eq expected
      end
    end

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
        assets_attributes item, params
      end

      it "to_s" do
        item.to_s.should eq format
      end
      
      describe "parse" do
        item = MediaItem.parse(format)
        assets_attributes item, params
      end
    end
  end
end

private def assets_attributes(item, params)
  it "type" do
    item.type.to_s.should eq params[:type]?.to_s
  end

  it "group_id" do
    item.group_id.to_s.should eq params[:group_id]?.to_s
  end

  it "language" do
    item.language.should eq params[:language]?
  end

  it "assoc_language" do
    item.assoc_language.should eq params[:assoc_language]?
  end

  it "name" do
    item.name.to_s.should eq params[:name]?.to_s
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
