require "./spec_helper"

module M3U8
  describe TimeItem do
    {
      {
        { time: "2010-02-19T14:54:23Z" },
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z"
      },
      {
        { time: "2010-02-19T14:54:23.031Z" },
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
      },
      {
        { time: Time.iso8601("2010-02-19T14:54:23.031Z") },
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
      }
    }.each do |(input, output)|
      it "should provide m3u8 format representation #{output}" do
        TimeItem.new(input).to_s.should eq output
      end
    end

    {
      {
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z",
        Time.iso8601("2010-02-19T14:54:23Z")
      },
      {
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z",
        Time.iso8601("2010-02-19T14:54:23.031Z")
      }
    }.each do |(input, output)|
      it "should parse m3u8 text into instance #{input}" do
        TimeItem.parse(input).time.should eq output
      end
    end
  end
end