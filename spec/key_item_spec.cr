require "./spec_helper"

module M3U8
  describe KeyItem do
    it "initialize with namedtuple" do
      tuple = {
        method:              "AES-128",
        uri:                 "http://test.key",
        iv:                  "D512BBF",
        key_format:          "identity",
        key_format_versions: "1/3",
      }

      item = KeyItem.new(tuple)
      item.method.should eq tuple[:method]
      item.uri.should eq tuple[:uri]
      item.iv.should eq tuple[:iv]
      item.key_format.should eq tuple[:key_format]
      item.key_format_versions.should eq tuple[:key_format_versions]
    end

    {
      {
        {
          method:              "AES-128",
          uri:                 "http://test.key",
          iv:                  "D512BBF",
          key_format:          "identity",
          key_format_versions: "1/3",
        },
        %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
      },
      {
        {
          method: "AES-128",
          uri:    "http://test.key",
        },
        %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key")
      },
      {
        {
          method: "NONE"
        },
        %(#EXT-X-KEY:METHOD=NONE)
      }
    }.each do |(input, output)|
      it "provide m3u8 format representation #{output}" do
        KeyItem.new(input).to_s.should eq output
      end
    end

    # it "should parse m3u8 format into instance" do
    #   format = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",) +
    #            %(IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    #   item = KeyItem.parse format
    #   item.method.should eq "AES-128"
    #   item.uri.should eq "http://test.key"
    #   item.iv.should eq "D512BBF"
    #   item.key_format.should eq "identity"
    #   item.key_format_versions.should eq "1/3"
    # end
  end
end
