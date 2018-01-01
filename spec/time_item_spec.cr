require "./spec_helper"

module M3U8
  describe TimeItem do
    {
      {
        "2010-02-19T14:54:23Z",
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z"
      },
      {
        "2010-02-19T14:54:23.031Z",
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
      },
      {
        Time.iso8601("2010-02-19T14:54:23.031Z"),
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
      },
      {
        { time: "2010-02-19T14:54:23Z" },
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z"
      },
      {
        { time: Time.iso8601("2010-02-19T14:54:23.031Z") },
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z"
      },
    }.each do |(params, format)|
      item = TimeItem.new(params)

      it "to_s" do
        item.to_s.should eq format
      end
    end

    # {
    #   {
    #     "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z",
    #     Time.iso8601("2010-02-19T14:54:23Z")
    #   },
    #   {
    #     "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z",
    #     Time.iso8601("2010-02-19T14:54:23.031Z")
    #   }
    # }.each do |(input, output)|
    #   it "should parse m3u8 text into instance #{input}" do
    #     TimeItem.parse(input).time.should eq output
    #   end
    # end
  end
end
