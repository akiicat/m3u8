require "./spec_helper"

module M3U8
  describe DiscontinuityItem do
    it "to_s" do
      item = DiscontinuityItem.new
      item.to_s.should eq "#EXT-X-DISCONTINUITY\n"
    end
  end
end
