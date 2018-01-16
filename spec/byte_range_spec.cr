require "./spec_helper"

private def assets(item, params, format)
  describe "initialize" do
    it "length" do
      item.length.should eq params[:length]
    end

    it "start" do
      item.start.should eq params[:start]?
    end
  end

  it "to_s" do
    item.to_s.should eq format
  end
end

module M3U8
  describe ByteRange do

    describe "initialize" do
      options = {
        length: 4500,
        start: 600
      }
      expected = "4500@600"

      pending "hash" do
        ByteRange.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        ByteRange.new(options).to_s.should eq expected
      end

      it "hash like" do
        ByteRange.new(**options).to_s.should eq expected
      end
      
      it "string format" do
        ByteRange.new(expected).to_s.should eq expected
      end
    end

    {
      {
        { length: 4500, start: 600 },
        "4500@600"
      },
      {
        { length: 4000, start: nil },
        "4000"
      },
      {
        { length: 3300 },
        "3300"
      },
    }.each do |(params, format)|
      assets ByteRange.new(params), params, format
      assets ByteRange.new(format), params, format
    end
  end
end
