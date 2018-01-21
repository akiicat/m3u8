require "./spec_helper"

module M3U8
  describe MapItem do

    describe "initialize" do
      options = {
        uri: "frelo/prog_index.m3u8",
        byterange: { length: 4500, start: 600 }
      }
      expected = %(#EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600")

      pending "hash" do
        MapItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        MapItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        MapItem.new(**options).to_s.should eq expected
      end
    end

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
          byterange: ByteRange.new(length: 4500, start: 600)
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
          uri: "frelo/prog_index.m3u8",
          byterange: ByteRange.new(length: 4500)
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
      item = MapItem.new(params)

      describe "initialize" do
        assets_attributes item, params
      end

      it "to_s" do
        item.to_s.should eq format
      end

      describe "parse" do
        item = MapItem.parse format
        assets_attributes item, params
      end
    end
  end
end

private def assets_attributes(item, params)
  it "uri" do
    item.uri.should eq params[:uri]
  end
  
  it "byterange" do
    item.byterange.should be_a(M3U8::ByteRange)
  end
end
