require "./spec_helper"

module M3U8
  describe TimeItem do
    {
      {
        "2010-02-19T14:54:23Z",
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z",
      },
      {
        "2010-02-19T14:54:23.031Z",
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z",
      },
      {
        Time.iso8601("2010-02-19T14:54:23.031Z"),
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z",
      },
      {
        {time: "2010-02-19T14:54:23Z"},
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23Z",
      },
      {
        {time: Time.iso8601("2010-02-19T14:54:23.031Z")},
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z",
      },
      {
        {time: Time.iso8601("2010-02-19T14:54:23.031+08:00")},
        "#EXT-X-PROGRAM-DATE-TIME:2010-02-19T14:54:23.031Z",
      },
    }.each do |(params, format)|
      item = TimeItem.new(params)

      it "to_s" do
        item.to_s.should eq format
      end

      it "not empty" do
        item.empty?.should be_false
      end
    end

    describe "empty?" do
      item = TimeItem.new

      it "initialize" do
        item.empty?.should be_true
      end

      it "give value" do
        item.time = Time.utc
        item.empty?.should be_false
      end
    end
  end
end
