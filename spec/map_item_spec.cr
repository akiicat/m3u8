require "./spec_helper"

module M3U8
  describe MapItem do
    {
      {
        {
          uri: "frelo/prog_index.m3u8",
          byterange: {
            length: 4500,
            start: 600
          }
        },
        %(#EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600")
      },
      {
        {
          uri: "frelo/prog_index.m3u8",
          byterange: {
            length: 4500
          }
        },
        %(#EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500")
      },
      {
        {
          uri: "frehi/prog_index.m3u8",
        },
        %(#EXT-X-MAP:URI="frehi/prog_index.m3u8")
      }
    }.each do |(params, format)|
      item = M3U8::MapItem.new(params)

      describe "initialize" do
        it "uri" do
          item.uri.should eq params[:uri]
        end

        it "byterange" do
          params_byterange = params[:byterange]?
          item_byterange = item.byterange

          if params_byterange && !item_byterange.nil?
            item_byterange.length.should eq params_byterange[:length]
            item_byterange.start.should eq params_byterange[:start]?
          else
            item_byterange.should eq params_byterange
          end
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end

    # it "should parse m3u8 text into instance" do
    #   input = "#EXT-X-MAP:URI="frelo/prog_index.m3u8"," \
    #     "BYTERANGE="3500@300""

    #   item = M3u8::MapItem.parse(input)

    #   expect(item.uri).to eq "frelo/prog_index.m3u8"
    #   expect(item.byterange.length).to eq 3500
    #   expect(item.byterange.start).to eq 300

    #   input = "#EXT-X-MAP:URI="frelo/prog_index.m3u8""

    #   item = M3u8::MapItem.parse(input)

    #   expect(item.uri).to eq "frelo/prog_index.m3u8"
    #   expect(item.byterange).to be_nil
    # end
  end
end
