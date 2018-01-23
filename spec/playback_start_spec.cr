require "./spec_helper"

module M3U8
  describe PlaybackStart do

    describe "initialize" do
      options = {
        time_offset: -12.9,
        precise: true
      }
      expected = "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES"

      pending "hash" do
        PlaybackStart.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        PlaybackStart.new(options).to_s.should eq expected
      end

      it "hash like" do
        PlaybackStart.new(**options).to_s.should eq expected
      end
    end

    {
      {
        {
          time_offset: -12.9,
          precise: true
        },
        "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=YES"
      },
      {
        {
          time_offset: -12.9,
          precise: false
        },
        "#EXT-X-START:TIME-OFFSET=-12.9,PRECISE=NO"
      },
      {
        {
          time_offset: 9.2,
          precise: true
        },
        "#EXT-X-START:TIME-OFFSET=9.2,PRECISE=YES"
      },
      {
        {
          time_offset: 9.2,
        },
        "#EXT-X-START:TIME-OFFSET=9.2"
      }
    }.each do |(params, format)|
      item = PlaybackStart.new(params)

      describe "initialize" do
        it "time_offset" do
          item.time_offset.should eq params[:time_offset]
        end

        it "precise" do
          item.precise.should eq params[:precise]?
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end

    describe "#parse" do
      it "parses tag with all attributes" do
        tag = "#EXT-X-START:TIME-OFFSET=20.0,PRECISE=YES"
        item = PlaybackStart.parse(tag)

        item.time_offset.should eq(20.0)
        item.precise.should be_true
      end

      it "parses tag without optional attributes" do
        tag = "#EXT-X-START:TIME-OFFSET=-12.9"
        item = PlaybackStart.parse(tag)

        item.time_offset.should eq(-12.9)
        item.precise.should be_nil
      end
    end
  end
end
