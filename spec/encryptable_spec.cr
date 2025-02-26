require "./spec_helper"

module M3U8
  include Encryptable

  class DummyEncryptable
    include Encryptable
  end

  describe Encryptable do
    describe "expand namedtuple" do
      it "full options" do
        options = {
          method:              "AES-128",
          uri:                 "http://test.key",
          iv:                  "D512BBF",
          key_format:          "identity",
          key_format_versions: "1/3",
        }
        expected = %(METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")

        DummyEncryptable.new(**options).attributes_to_s.should eq expected
      end

      it "partial options" do
        options = {
          method: "AES-128",
          uri:    "http://test.key",
        }
        expected = %(METHOD=AES-128,URI="http://test.key")

        DummyEncryptable.new(**options).attributes_to_s.should eq expected
      end
    end

    describe "convert_key" do
      it "raise if METHOD not provided" do
        expect_raises(KeyError) do
          Encryptable.convert_key({"URI" => "http://test.key"})
        end
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
        {
          "METHOD"            => "AES-128",
          "URI"               => "http://test.key",
          "IV"                => "D512BBF",
          "KEYFORMAT"         => "identity",
          "KEYFORMATVERSIONS" => "1/3",
        },
        %(METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3"),
      },
      {
        {
          method: "AES-128",
          uri:    "http://test.key",
        },
        {
          "METHOD" => "AES-128",
          "URI"    => "http://test.key",
        },
        %(METHOD=AES-128,URI="http://test.key"),
      },
      {
        {
          method: "NONE",
        },
        {
          "METHOD" => "NONE",
        },
        %(METHOD=NONE),
      },
    }.each do |(params, params_h, format)|
      item = DummyEncryptable.new(params)
      item_namedtuple = Encryptable.convert_key(params_h)

      pending "hash" do
        DummyEncryptable.new(params.to_h).attributes_to_s.should eq format
      end

      describe "initialize" do
        assets_attributes item, params
      end

      describe "convert_key" do
        assets_symbol_attributes item_namedtuple, params
      end

      it "attributes_to_s" do
        item.attributes_to_s.should eq format
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

private def assets_symbol_attributes(item, params)
  it "method" do
    item[:method].should eq params[:method]
  end

  it "uri" do
    item[:uri].should eq params[:uri]?
  end

  it "iv" do
    item[:iv].should eq params[:iv]?
  end

  it "key_format" do
    item[:key_format].should eq params[:key_format]?
  end

  it "key_format_versions" do
    item[:key_format_versions].should eq params[:key_format_versions]?
  end
end
