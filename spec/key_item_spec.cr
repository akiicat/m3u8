require "./spec_helper"

module M3U8
  describe KeyItem do
    describe "initialize" do
      options = {
        method:              "AES-128",
        uri:                 "http://test.key",
        iv:                  "D512BBF",
        key_format:          "identity",
        key_format_versions: "1/3",
      }
      expected = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")

      pending "hash" do
        KeyItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        KeyItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        KeyItem.new(**options).to_s.should eq expected
      end
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
        %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3"),
      },
      {
        {
          method: "AES-128",
          uri:    "http://test.key",
        },
        %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key"),
      },
      {
        {
          method: "NONE",
        },
        %(#EXT-X-KEY:METHOD=NONE),
      },
    }.each do |(params, format)|
      item = KeyItem.new(params)

      describe "initialize" do
        assets_attributes item, params
      end

      it "to_s" do
        item.to_s.should eq format
      end

      describe "parse" do
        item = KeyItem.parse format
        assets_attributes item, params
      end
    end
  end
end

private def assets_attributes(item, params)
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
