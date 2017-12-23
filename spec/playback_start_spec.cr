require "./spec_helper"

module M3U8
  describe PlaybackStart do
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

    # describe "#parse" do
    #   it "parses tag with all attributes" do
    #     start = described_class.new
    #     tag = "#EXT-X-START:TIME-OFFSET=20.0,PRECISE=YES"
    #     start.parse(tag)

    #     expect(start.time_offset).to eq(20.0)
    #     expect(start.precise).to be true
    #   end

    #   it "parses tag without optional attributes" do
    #     start = described_class.new
    #     tag = "#EXT-X-START:TIME-OFFSET=-12.9"
    #     start.parse(tag)

    #     expect(start.time_offset).to eq(-12.9)
    #     expect(start.precise).to be_nil
    #   end
    # end

  end
end
