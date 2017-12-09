require "./spec_helper"

private def session_key_assets(input)
  item = M3U8::SessionKeyItem.new(input)

  {% for key, index in %w(method uri iv key_format key_format_versions) %}
    item.{{key.id}}.should eq input[:{{key.id}}]?
  {% end %}
end

module M3U8
  describe SessionDataItem do
    {
      {
        {
          data_id: "com.test.movie.title",
          value: "Test",
          uri: "http://test",
          language: "en"
        },
        %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",URI="http://test",LANGUAGE="en")
      },
      {
        {
          data_id: "com.test.movie.title",
          value: "Test",
          language: "en"
        },
        %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",LANGUAGE="en")
      },
      {
        {
          data_id: "com.test.movie.title",
          uri: "http://test",
          language: "en"
        },
        %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",URI="http://test",LANGUAGE="en")
      }
    }.each do |(input, output)|
      item = SessionDataItem.new(input)

      it "should initialize with hash" do
        {% for key, index in %w(data_id value uri language) %}
          item.{{key.id}}.should eq input[:{{key.id}}]?
        {% end %}
      end

      it "should provide m3u8 format representation" do
        item.to_s.should eq output
      end
    end

    # it "should parse m3u8 format into instance" do
    #   format = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
    #     %(VALUE="Test",LANGUAGE="en")
    #   item = SessionDataItem.parse format
    #   item.data_id.should eq "com.test.movie.title"
    #   item.value.should eq "Test"
    #   item.uri.should be_nil
    #   item.language.should eq "en"

    #   format = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) +
    #     %(URI="http://test",LANGUAGE="en")
    #   item = SessionDataItem.parse format
    #   item.data_id.should eq "com.test.movie.title"
    #   item.value.should be_nil
    #   item.uri.should eq "http://test"
    #   item.language.should eq "en"
    # end
  end
end
