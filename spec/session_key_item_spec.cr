require "./spec_helper"

module M3U8
  describe SessionKeyItem do
    {
      {
        {
          method: "AES-128",
          uri: "http://test.key",
          iv: "D512BBF",
          key_format: "identity",
          key_format_versions: "1/3"
        },
        %(#EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
      },
      {
        {
          method: "AES-128",
          uri: "http://test.key"
        },
        %(#EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://test.key")
      },
      {
        {
          method: "NONE"
        },
        "#EXT-X-SESSION-KEY:METHOD=NONE"
      }
    }.each do |(params, format)|
      item = SessionKeyItem.new(params)

      describe " initialize" do
        it "method" do
          item.method.should eq params[:method]
        end

        it "uri" do
          item.uri.should eq params[:uri]?
        end

        it "iv" do
          item.iv.should eq params[:iv]?
        end

        it "key_format" do
          item.key_format.should eq params[:key_format]?
        end

        it "key_format_versions" do
          item.key_format_versions.should eq params[:key_format_versions]?
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end

    # it "should parse m3u8 format into instance" do
    #   format = %(#EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://test.key",) +
    #            %(IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    #   item = KeyItem.parse format
    #   expect(item.method).to eq "AES-128"
    #   expect(item.uri).to eq "http://test.key"
    #   expect(item.iv).to eq "D512BBF"
    #   expect(item.key_format).to eq "identity"
    #   expect(item.key_format_versions).to eq "1/3"
    # end
  end
end