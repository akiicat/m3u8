require "./spec_helper"

private def session_key_assets(input)
  item = M3U8::SessionKeyItem.new(input)

  {% for key, index in %w(method uri iv key_format key_format_versions) %}
    item.{{key.id}}.should eq input[:{{key.id}}]?
  {% end %}
end

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
    }.each do |(input, output)|
      it "should initialize with hash" do
        session_key_assets(input)
      end

      it "should provide m3u8 format representation #{output}" do
        SessionKeyItem.new(input).to_s.should eq output
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
