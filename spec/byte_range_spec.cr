require "./spec_helper"

private def assert_format(input, output)
  M3U8::ByteRange.new(**input).to_s.should eq output
end

private def assert_parse(input, output)
  range = M3U8::ByteRange.parse(input)
  range.length.should eq output[:length]
  range.start.should eq output[:start]?
end

module M3U8
  describe ByteRange do
    it "should provide m3u8 format representation" do
      assert_format({ length: 4500, start: 600 }, "4500@600")
      assert_format({ length: 4000, start: nil }, "4000")
      assert_format({ length: 3300 }, "3300")
    end

    it "should parse instance from string" do
      assert_parse("3500@300", { length: 3500, start: 300 })
      assert_parse("4000", { length: 4000 })
    end
  end
end
